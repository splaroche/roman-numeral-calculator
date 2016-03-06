class RomanNumeral
  class Numeral
    attr_accessor :numeral
    attr_reader :count

    def initialize(numeral, count=0)
      @numeral = numeral
      @count = count
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

  def initialize(roman_numeral)
    @numerals = [
        Numeral.new('M'),
        Numeral.new('CM'),
        Numeral.new('D'),
        Numeral.new('CD'),
        Numeral.new('C'),
        Numeral.new('XC'),
        Numeral.new('L'),
        Numeral.new('XL'),
        Numeral.new('X'),
        Numeral.new('IX'),
        Numeral.new('V'),
        Numeral.new('IV'),
        Numeral.new('I')
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
      if @numerals.any? { |v| v.numeral == double_numeral }
        numeral = double_numeral
        skip_character = true
      end
      @numerals.select { |v| v.numeral == numeral }[0].count += 1
    end
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

    # 3. sort the symbols largest <= left
    # sorted_numerals = order_numerals(catenated)
    # 4. start at right end and combine any of the same symbols
    #    that can be combined into a larger one
    catenated.reverse_each do |v|
      if v.count == 0
        next
      end
      next_numeral = @@NEXT_NUMERALS[v.numeral]
      unless next_numeral.nil?
        number_to_replace = v.count / next_numeral[1]
        v.count -= number_to_replace * next_numeral[1]
        catenated.select { |n| n.numeral == next_numeral[0] }[0].count += number_to_replace
      end
    end

    # 5. substitute any subtractives
    catenated.reverse_each do |v|
      if v.count == 0
        next
      end

      # Solo substitutes are always a combination of 4.
      substitute = @@SOLO_SUBTITUTE_NUMERALS[v.numeral]
      unless substitute.nil?
        number_to_substitute = v.count / 4
        v.count -= number_to_substitute * 4
        catenated.select{ |n| n.numeral == substitute }[0].count += number_to_substitute
      end

      # Double substitutions combine two numerals.  Because we're reversing through the sorted array,
      # we'll hit the initial double substitution numeral first.  The second character will be the second numeral to
      # combine with.
      double_substitute = @@DOUBLE_SUBSTITUE_NUMERALS[v.numeral]
      unless double_substitute.nil?
        second_numeral = catenated.select{ |n| n.numeral == v.numeral[1] }[0]
        number_to_substitute = [v.count, second_numeral.count].max
        second_numeral.count -= number_to_substitute
        v.count -= number_to_substitute
        catenated.select{ |n| n.numeral == double_substitute }[0].count += number_to_substitute
      end
    end

    return RomanNumeral.new catenated.select { |x| x.count >= 1 }.join
  end

  def to_s
    return @numerals.select { |x| x.count > 0 }.join
  end
end