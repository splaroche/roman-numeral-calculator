class RomanNumeral
  class NumeralNode
    attr_accessor :numeral, :next, :previous
    attr_reader :count

    def initialize(numeral, count=0, next_node=nil, previous=nil)
      @numeral = numeral
      @count = count
      @next = next_node
      @previous = previous
    end

    def count=(new_count)
      if new_count < 0
        @count = 0
      else
        @count = new_count
      end
    end

    def to_s
      @numeral * @count
    end
  end

  @@EXPLODED_NUMERALS = {
      'IV' => ['I', 4],
      'IX' => ['I', 9],
      'XL' => ['X', 4],
      'XC' => ['X', 9],
      'CD' => ['C', 4],
      'CM' => ['C', 9]
  }

  @@NEXT_NUMERALS = {
      'I' => ['V', 5],
      'V' => ['X', 2],
      'X' => ['L', 5],
      'L' => ['C', 2],
      'C' => ['D', 5],
      'D' => ['M', 2]
  }

  @@SUBTRACTION_EXPLOSIONS = {
      'V' => [['I', 5]],
      'X' => [['V', 2]],
      'L' => [['X', 5]],
      'C' => [['L', 1], ['X', 5]],
      'D' => [['C', 4], ['L', 2]],
  }

  @@SOLO_SUBTITUTE_NUMERALS = {
      'I' => 'IV',
      'X' => 'XL',
      'C' => 'CD'
  }

  @@DOUBLE_SUBSTITUE_NUMERALS = {
      'IV' => 'IX',
      'XL' => 'XC',
      'CD' => 'CM'
  }

  @@NUMERAL_ORDER = [
      'M',
      'CM',
      'D',
      'CD',
      'C',
      'XC',
      'L',
      'XL',
      'X',
      'IX',
      'V',
      'IV',
      'I'
  ]

  def initialize(roman_numeral)
    @first_numeral = nil
    @last_numeral = nil
    @numerals = [

    ]
    @original_numeral = roman_numeral
    parse_numerals(roman_numeral)
  end

  private def parse_numerals(numeral)
    skip_character = false
    unprocessed_numerals = numeral.split ''
    (0..unprocessed_numerals.length - 1).each do |pos|
      next_pos = pos + 1
      numeral = unprocessed_numerals[pos]
      if skip_character
        skip_character = false
        next
      end

      double_numeral = unprocessed_numerals.values_at(pos, next_pos).join('')
      if @@NUMERAL_ORDER.any? { |v| v == double_numeral }
        numeral = double_numeral
        skip_character = true
      end
      @numerals.select { |v| v.numeral == numeral }[0].count += 1
    end
  end

  private def combine_numerals(orig_numerals)
    numerals = Marshal.load(Marshal.dump(orig_numerals))
    numerals.reverse_each do |v|
      if v.count == 0
        next
      end
      next_numeral = @@NEXT_NUMERALS[v.numeral]
      unless next_numeral.nil?
        number_to_replace = v.count / next_numeral[1]
        v.count -= number_to_replace * next_numeral[1]
        numerals.select { |n| n.numeral == next_numeral[0] }[0].count += number_to_replace
      end
    end
    return numerals
  end

  private def substitute_numerals(orig_numerals)
    substituted = Marshal.load(Marshal.dump(orig_numerals))
    substituted.reverse_each do |v|
      if v.count == 0
        next
      end

      # Solo substitutes are always a combination of 4.
      substitute = @@SOLO_SUBTITUTE_NUMERALS[v.numeral]
      unless substitute.nil?
        number_to_substitute = v.count / 4
        v.count -= number_to_substitute * 4
        substituted.select { |n| n.numeral == substitute }[0].count += number_to_substitute
      end

      # Double substitutions combine two numerals.  Because we're reversing through the sorted array,
      # we'll hit the initial double substitution numeral first.  The second character will be the second numeral to
      # combine with.
      double_substitute = @@DOUBLE_SUBSTITUE_NUMERALS[v.numeral]
      unless double_substitute.nil?
        second_numeral = substituted.select { |n| n.numeral == v.numeral[1] }[0]
        number_to_substitute = [v.count, second_numeral.count].max
        second_numeral.count -= number_to_substitute
        v.count -= number_to_substitute
        substituted.select { |n| n.numeral == double_substitute }[0].count += number_to_substitute
      end
    end
    return substituted
  end

  # Get next highest numeral with a count.
  private def get_higher_numeral(numeral)

  end

  def exploded_numerals
    numerals = self.numerals
    numerals.each do |v|
      if v.count == 0
        next
      end
      exploded_numeral = @@EXPLODED_NUMERALS[v.numeral]
      unless exploded_numeral.nil?
        number_to_explode = v.count * exploded_numeral[1]
        v.count -= number_to_explode / exploded_numeral[1]
        numerals.select { |n| n.numeral == exploded_numeral[0] }[0].count += number_to_explode
      end
    end
    return numerals
  end

  def numerals
    Marshal.load(Marshal.dump(@numerals))
  end

  def +(other)
    # 1. substitute the exploded (subtractive) values
    self_numerals = self.exploded_numerals
    other_numerals = other.exploded_numerals

    # 2. catenate the values
    catenated = self_numerals
    other_numerals.each do |v|
      if v.count == 0
        next
      end
      catenated.select { |n| n.numeral == v.numeral }[0].count += v.count
    end

    # 3. sort the symbols largest <= left (Already done)

    # 4. start at right end and combine any of the same symbols
    #    that can be combined into a larger one
    catenated = combine_numerals(catenated)

    # 5. substitute any subtractives
    substituted = substitute_numerals(catenated)

    return RomanNumeral.new substituted.select { |x| x.count >= 1 }.join
  end

  def -(other)
    # 1. Substitute for any subtractives in both values.
    self_numerals = self.exploded_numerals
    other_numerals = other.exploded_numerals


    # 2. Any symbols occurring in the second value are "crossed out" in the first.
    other_numerals.reverse_each do |v|
      if v.count == 0
        next
      end
      matching_numeral = self_numerals.select{ |n| n.numeral == v.numeral }[0]

    #     If the symbol appears in the first, simply cross it out.
    #     If not, then convert a "larger" symbol into appropriate multiples of the needed one, then cross out.
      if matching_numeral.count < v.count
        # Find the next highest numeral and explode it.
        # TODO: This needs to continue up the array until the next highest value is found.  I might need some sort
        # TODO: tree to map all the values.  Alternatively, a recursive function that keeps going up, using the mappings
        # TODO: to figure out the exploded value, then pass it back down the line.  Hence X -> L -> C -> 2*L -> 10*X.
        # TODO: Although, only the MINIMUM number of Xs need to be generated, this should be safe, since we combine
        # TODO: the numerals into higher numerals in the next step.
        next_numeral = @@NEXT_NUMERALS[v.numeral]
        next_found_numeral = self_numerals.select{ |n| n.numeral == next_numeral[0] }[0]
        number_to_explode = next_found_numeral.count * next_numeral[1]
        next_found_numeral.count = 0
        matching_numeral.count += number_to_explode
      end

      matching_numeral.count -= v.count
    end

    # 3. Rewrite without the crossed out symbols.
    # 4. Check for any groupings of the same symbol that needs to be replaced with a "larger" one.
    combined = combine_numerals(self_numerals)
    # 5. Compact the result by substituting subtractives where possible.
    substituted = substitute_numerals(combined)

    return RomanNumeral.new substituted.select { |x| x.count >= 1 }.join
  end

  def to_s
    return @numerals.select { |x| x.count > 0 }.join
  end
end