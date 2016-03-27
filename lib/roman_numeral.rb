require_relative 'numeral'

class RomanNumeral
  attr_reader :numerals

  def initialize(roman_numeral)
    @numerals = []
    @original_numeral = roman_numeral
    parse_numerals(roman_numeral)
  end

  # Accessor
  def numerals
    numerals.dup
  end


  def combine_numerals(orig_numerals)
    combined = []
    counts = get_numeral_counts(orig_numerals)
    keys = counts.keys.sort_by { |x| Numeral.ORDER_OF_PRECEDENCE.index x }
    keys.each do |k|
      v = counts[k]
      next_numeral, replacement_count = k.get_next
      if next_numeral.nil?
        next
      end

      count, replacement_count = get_replacement_counts(v, replacement_count)
      counts[k] = count
      unless counts.has_key? next_numeral
        counts[next_numeral] = 0
      end
      counts[next_numeral] += replacement_count
    end

    counts.each { |k, v| combined.concat [k] * v if v > 0 }
    combined.sort!

    return combined
  end

  def exploded_numerals
    exploded = []
    @numerals.each do |i|
      exploded.concat i.get_exploded
    end
    exploded.sort!
    return exploded
  end

  def get_numeral_breakdown(numeral, larger_numeral)
    # We want to breakdown the larger_numeral until we have a smaller numeral
    broken_numerals = []
    breaking_numeral = larger_numeral
    until broken_numerals.include?(numeral)
      broken = breaking_numeral.get_subtractive
      # Get the final numerals subtractives
      next_broken = broken.last.get_subtractive
      unless next_broken.empty?
        broken.pop
      end
      broken_numerals.concat broken
      breaking_numeral = broken.first
    end
    return broken_numerals
  end

  def get_numeral_counts(count_numerals)
    counts = Hash.new(0)
    count_numerals.each do |numeral|
      counts[numeral] += 1
    end
    return counts
  end

  def get_replacement_counts(count, replacement_number)
    replacement_count = count / replacement_number
    remaining_count = count - (replacement_count * replacement_number)
    return remaining_count, replacement_count
  end

  def parse_numerals(numeral)
    numerals = []
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
      if Numeral.ORDER_OF_PRECEDENCE.any? { |v| v == double_numeral }
        numeral = double_numeral
        skip_character = true
      end
      @numerals.push(Numeral.new numeral)
    end
    @numerals.sort!
  end

  def remove_duplicates(first_list, counts)
    subtracted = first_list.reject { |e| counts[e] -= 1 unless counts[e].zero? }
    subtracted.sort!
    return subtracted, counts
  end

  def substitute_double_numerals(orig_numerals)
    substituted = []
    counts = get_numeral_counts(orig_numerals)
    keys = counts.keys.sort_by { |x| Numeral.ORDER_OF_PRECEDENCE.index x }
    keys.each do |k|
      v = counts[k]
      double_substitute = k.double_substitution
      unless double_substitute.nil?
        second_numeral = k.get_second_substitute_part
        second_count = counts[second_numeral]
        unless second_numeral.nil? and second_count.nil?
          number_to_substitute = [v, second_count].min
          counts[second_numeral] -= number_to_substitute
          counts[k] -= number_to_substitute
          unless counts.has_key? double_substitute
            counts[double_substitute] = 0
          end
          counts[double_substitute] += number_to_substitute
        end
      end
    end
    counts.each { |k, v| substituted.concat [k] * v if v > 0 }
    substituted.sort!

    return substituted
  end


  def substitute_solo_numerals(orig_numerals)
    substituted = []
    counts = get_numeral_counts(orig_numerals)
    keys = counts.keys.sort_by { |x| Numeral.ORDER_OF_PRECEDENCE.index x }
    keys.each do |k|
      v = counts[k]
      unless k.solo_substitution.nil?
        count, replacement_count = get_replacement_counts(v, 4)
        counts[k] = count
        unless counts.has_key? k.solo_substitution
          counts[k.solo_substitution] = 0
        end
        counts[k.solo_substitution] += replacement_count
      end
    end

    counts.each { |k, v| substituted.concat [k] * v if v > 0 }
    substituted.sort!

    return substituted
  end

  def +(other)
    # 1. substitute the exploded (subtractive) values
    self_numerals = self.exploded_numerals
    other_numerals = other.exploded_numerals

    # 2. catenate the values
    catenated = self_numerals
    catenated.concat(other_numerals)
    # 3. sort the symbols largest => right
    catenated.sort!

    # 4. start at right end and combine any of the same symbols
    #    that can be combined into a larger one
    combined = combine_numerals(catenated)

    # 5. substitute any subtractives
    substituted = substitute_solo_numerals(combined)
    substituted = substitute_double_numerals(substituted)

    return RomanNumeral.new substituted.reverse.join
  end

  def -(other)
    # 1. Substitute for any subtractives in both values.
    self_numerals = self.exploded_numerals
    other_numerals = other.exploded_numerals


    # 2. Any symbols occurring in the second value are "crossed out" in the first.
    #     If the symbol appears in the first, simply cross it out.
    #     If not, then convert a "larger" symbol into appropriate multiples of the needed one, then cross out.
    # first pass
    counts = other_numerals.inject(Hash.new(0)) { |h, v| h[v] += 1; h }
    combined, counts = remove_duplicates(self_numerals, counts)

    remaining_other = counts.select { |k, v| v > 0 }
    until remaining_other.empty?
      keys = remaining_other.keys.sort_by { |x| Numeral.ORDER_OF_PRECEDENCE.index x }
      keys.each do |k|
        # find the first numeral that is larger than the current key
        unless combined.include? k
          next_largest = combined.select { |x| x > k }.first
          combined.delete(next_largest)
          combined.concat get_numeral_breakdown(k, next_largest)
          combined.sort!
        end
      end
      combined, counts = remove_duplicates(combined, counts)
      remaining_other = counts.select { |k, v| v > 0 }
    end

    # 3. Rewrite without the crossed out symbols.
    # Done

    # 4. Check for any groupings of the same symbol that needs to be replaced with a "larger" one.
    combined = combine_numerals(combined)
    # 5. Compact the result by substituting subtractives where possible.
    substituted = substitute_solo_numerals(combined)
    substituted = substitute_double_numerals(substituted)

    return RomanNumeral.new substituted.reverse.join
  end

  def to_s
    # Order of writing is always largest -> smallest
    @numerals.reverse.join
  end

  private :combine_numerals, :get_numeral_breakdown, :get_numeral_counts, :get_replacement_counts, :parse_numerals,
          :substitute_solo_numerals, :substitute_double_numerals

end