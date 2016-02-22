class RomanNumeral
  # The order reflects the order the numerals should appear from left to right
  @@ordered_mapping = %w(M CM D CD C XC L XL X IX V IV I)

  # The next highest numeral for when we need to combined 5 X into an L
  @@next_highest_mapping = {
      'D' => ['M', 2],
      'C' => ['D', 5],
      'L' => ['C', 2],
      'X' => ['L', 5],
      'V' => ['X', 2],
      'I' => ['V', 5]
  }

  # Straight arabic amounts.
  @@roman_to_arabic_mapping = {
      'M' => 1000,
      'CM' => 900,
      'D' => 500,
      'CD' => 400,
      'C' => 100,
      'XC' => 90,
      'L' => 50,
      'XL' => 50,
      'X' => 10,
      'IX' => 9,
      'V' => 5,
      'IV' => 4,
      'I' => 1,
  }

  @@exploded_mapping = {
      'IV' => 'IIII',
      'IX' => 'VIIII',
      'XL' => 'XXXX',
      'XC' => 'LXXXX',
      'CD' => 'CCCC',
      'CM' => 'DCCCC',
  }


  def initialize(roman_numeral)
    @original_numeral = roman_numeral
    parsed_numerals = parse_numerals(roman_numeral)
    puts "parsed numerals #{parsed_numerals}"
    exploded_numerals = exploded(parsed_numerals)
    puts "exploded numerals #{exploded_numerals}"
    replaced_numerals = replace_with_larger(exploded_numerals)
    puts "replaced numerals #{replaced_numerals}"
    @numerals = order_numerals(replaced_numerals)

    # puts "original: #{@original_numeral}"
    # puts "ordered: #{self.to_s}"
  end

  private def parse_numerals(numeral)
    number = 0
    skip_numeral = false
    unprocessed_numerals = numeral.split ''
    numerals = []
    (0..unprocessed_numerals.length - 1).each do |pos|
      next_pos = pos + 1
      numeral = unprocessed_numerals[pos]
      if skip_numeral
        skip_numeral = false
        next
      end

      double_numeral = unprocessed_numerals.values_at(pos, next_pos).join('')
      double_mapping = @@roman_to_arabic_mapping[double_numeral]
      unless double_mapping.nil?
        numerals.push(double_numeral)
        skip_numeral = true
      else
        numerals.push(numeral)
      end
    end
    # puts "Final amount #{amount}"
    return numerals
  end

  private def order_numerals(numerals)
    ordered_numerals = numerals.sort_by { |x| @@ordered_mapping.index(x)}
    return ordered_numerals
  end

  private def replace_with_larger(numerals)
    number_of_each_numeral = numerals.each_with_object(Hash.new(0)) { |word,counts| counts[word] += 1 }
    number_of_each_numeral.reverse_each do |k,v|
      next_highest = @@next_highest_mapping[k]
      if next_highest.nil?
        next
      end
      next_highest_numeral = next_highest[0]
      next_highest_multiplier = next_highest[1]
      amount_extra = v / next_highest_multiplier
      if amount_extra > 0
        number_of_each_numeral[next_highest_numeral] += amount_extra
        next_highest_numeral[k] = v - (amount_extra * next_highest_multiplier)
      end
    end
    replaced_numerals = expand_numerals_by_count(number_of_each_numeral)
    return replaced_numerals
  end

  private def expand_numerals_by_count(numerals)
    replaced_numerals = []
    numerals.each do |k, v|
      # not ideal
      numeral = (k * v).split('')
      puts "numeral #{numeral}"
      replaced_numerals.push(*numeral)
    end
    replaced_numerals
  end

  private def exploded(numerals)
    exploded = []
    numerals.each do |i|
      exploded_numeral = @@exploded_mapping.fetch(i, default=i).split
      exploded.push(*exploded_numeral)
    end
    return exploded
  end

  # TODO: This method cannot run before replace_with_larger or bad things might happen such as VV turning into something weird.
  private def unexplode(numerals)
    number_of_each_numeral = numerals.each_with_object(Hash.new(0)) { |word,counts| counts[word] += 1 }
    # We need to reverse the order of the numerals so that we can start at I and go from there.
    @@ordered_mapping.reverse_each do |i|
      amount = number_of_each_numeral[i]
      next_highest = @@next_highest_mapping[i]
      if amount == 0 or next_highest.nil?
        next
      end
      puts "amount of #{i} is #{amount}"
      next_highest_numeral = next_highest[0]
      # The subtractives start at one less than the next highest numeral
      combining_minimum_amount = next_highest[1] - 1
      # If we have less than the combining amount, skip
      # Since we have to run replace_with_larger first, so we shouldn't have more than this combining_minimum_amount
      if amount < combining_minimum_amount
        next
      end

      number_of_next_highest = number_of_each_numeral[next_highest_numeral]
      # Remove the combining amount and one from the next highest amount
      if number_of_next_highest > 0
        number_of_each_numeral[next_highest_numeral] -= 1
      end
      number_of_each_numeral[i] -= combining_minimum_amount
      # Get the proper map
      exploded_numeral = next_highest_numeral + (i * amount)
      substutive_map = @@exploded_mapping.key(exploded_numeral)
      number_of_each_numeral[substutive_map] = 1
    end
    # puts "Unexploded numerals: #{number_of_each_numeral}"
    replaced_numerals = expand_numerals_by_count(number_of_each_numeral)
    return replaced_numerals
  end

  def +(other)
    # 1. substitute the exploded (subtractive) values
    # 2. catenate the values
    # 3. sort the symbols largest <= left
    # 4. start at right end and combine any of the same symbols that can make
    #    that can be combined into a larger one
    # 5. substitute any subtractives
  end

  def to_i
    return @numerals.inject(0) { |sum, x| sum + @@roman_to_arabic_mapping[x] }
  end

  def to_s
    return order_numerals(unexplode(@numerals)).join
  end
end