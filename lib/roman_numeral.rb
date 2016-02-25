
class RomanNumeral
  class Numeral
    attr_accessor :count, :numeral, :next_numeral, :next_numeral_combine_number, :order, :number, :exploded_numeral, :number_to_explode, :combines_with, :combines_into

    def initialize(numeral)
      @count = 0
      send("new_#{numeral.downcase}")
    end

    def new_m
      @numeral = 'M'
      @next_numeral = nil
      @next_numeral_combine_number = nil
      @order = 0
      @number = 1000
      @exploded_numeral = @numeral
      @number_to_explode = 1
    end

    def new_cm
      @numeral = 'CM'
      @next_numeral = nil
      @next_numeral_combine_number = nil
      @order = 1
      @number = 900
      @exploded_numeral = 'C'
      @number_to_explode = 9
    end

    def new_d
      @numeral = 'D'
      @next_numeral = 'M'
      @next_numeral_combine_number = 2
      @order = 3
      @number = 500
      @exploded_numeral = @numeral
      @number_to_explode = 1
      @combines_with = 'CD'
      @combines_into = 'CM'
    end

    def new_cd
      @numeral = 'CD'
      @next_numeral = nil
      @next_numeral_combine_number = nil
      @order = 4
      @number = 400
      @exploded_numeral = 'C'
      @number_to_explode = 4
      @combines_with = 'D'
      @combines_into = 'CM'
    end

    def new_c
      @numeral = 'C'
      @next_numeral = 'D'
      @next_numeral_combine_number = 5
      @order = 5
      @number = 100
      @exploded_numeral = @numeral
      @number_to_explode = 1
    end

    def new_xc
      @numeral = 'XC'
      @next_numeral = nil
      @next_numeral_combine_number = nil
      @order = 6
      @number = 90
      @exploded_numeral = 'X'
      @number_to_explode = 9
    end

    def new_l
      @numeral = 'L'
      @next_numeral = 'C'
      @next_numeral_combine_number = 2
      @order = 7
      @number = 50
      @exploded_numeral = @numeral
      @number_to_explode = 1
      @combines_with = 'XL'
      @combines_into = 'XC'
    end

    def new_xl
      @numeral = 'XL'
      @next_numeral = nil
      @next_numeral_combine_number = nil
      @order = 8
      @number = 40
      @exploded_numeral = 'X'
      @number_to_explode = 4
      @combines_with = 'L'
      @combines_into = 'XC'
    end

    def new_x
      @numeral = 'X'
      @next_numeral = 'L'
      @next_numeral_combine_number = 5
      @order = 9
      @number = 10
      @exploded_numeral = @numeral
      @number_to_explode = 1
    end

    def new_ix
      @numeral = 'IX'
      @next_numeral = nil
      @next_numeral_combine_number = nil
      @order = 10
      @number = 9
      @exploded_numeral = 'I'
      @number_to_explode = 9
    end

    def new_v
      @numeral = 'V'
      @next_numeral = 'X'
      @next_numeral_combine_number = 2
      @order = 11
      @number = 5
      @exploded_numeral = @numeral
      @number_to_explode = 1
      @combines_with = 'IV'
      @combines_into = 'IX'
    end

    def new_iv
      @numeral = 'IV'
      @next_numeral = nil
      @next_numeral_combine_number = nil
      @order = 12
      @number = 4
      @exploded_numeral = 'I'
      @number_to_explode = 4
      @combines_with = 'V'
      @combines_into = 'IX'
    end

    def new_i
      @numeral = 'I'
      @next_numeral = 'V'
      @next_numeral_combine_number = 5
      @order = 13
      @number = 1
      @exploded_numeral = @numeral
      @number_to_explode = 1
      @combines_with = 'I'
      @combines_into = 'IV'
    end

    def get_exploded
      if @exploded_numeral.nil?
        return nil
      end
      number = @number_to_explode * @count
      exploded = Numeral.new @exploded_numeral
      exploded.count = number
      @count -= number
      return exploded
    end

    def get_next
      if @next_numeral.nil?
        return nil
      end
      number = @count / @next_numeral_combine_number
      if number >= 1
        new_numeral = Numeral.new @next_numeral
        new_numeral.count += number
        @count -= number
        return new_numeral
      end
    end

    def get_subtractive
      return @combines_with
    end

    def get_subtractive_combination
      return @combines_into
    end

    def to_i
      @count * @number
    end

    def to_s
      @numeral * @count
    end
  end



  def initialize(roman_numeral)
    @numerals = {
        'M' => Numeral.new('M'),
        'CM' => Numeral.new('CM'),
        'D' => Numeral.new('D'),
        'CD' => Numeral.new('CD'),
        'C' => Numeral.new('C'),
        'XC' => Numeral.new('XC'),
        'L' => Numeral.new('L'),
        'XL' => Numeral.new('XL'),
        'X' => Numeral.new('X'),
        'IX' => Numeral.new('IX'),
        'V' => Numeral.new('V'),
        'IV' => Numeral.new('IV'),
        'I' => Numeral.new('I')
    }
    @original_numeral = roman_numeral
    parse_numerals(roman_numeral)
    # puts "parsed numerals #{parsed_numerals}"
    # @exploded = explode_substitives(parsed_numerals)
    # puts "exploded numerals #{@exploded}"
    # replaced_numerals = replace_with_larger(@exploded)
    # puts "replaced numerals #{replaced_numerals}"
    # @numerals = order_numerals(replaced_numerals)

    # puts "original: #{@original_numeral}"
    # puts "ordered: #{self.to_s}"
  end

  private def parse_numerals(numeral)
    number = 0
    skip_character = false
    unprocessed_numerals = numeral.split ''
    processed_numerals = []
    (0..unprocessed_numerals.length - 1).each do |pos|
      next_pos = pos + 1
      numeral = unprocessed_numerals[pos]
      if skip_character
        skip_character = false
        next
      end

      double_numeral = unprocessed_numerals.values_at(pos, next_pos).join('')
      double_mapping = @numerals[double_numeral]
      if double_mapping.nil?
        # numerals.push(numeral)
        @numerals[numeral].count += 1
      else
        @numerals[double_numeral].count += 1
        skip_character = true
      end
    end
  end

  def numerals
    Marshal.load(Marshal.dump(@numerals))
  end

  def +(other)
    # 1. substitute the exploded (subtractive) values
    self_numerals = self.numerals
    self_numerals.values.each do |x|
      next_numeral = x.get_exploded
      unless next_numeral.nil?
        self_numerals[next_numeral.numeral].count += next_numeral.count
      end
    end
    other_numerals = other.numerals
    other_numerals.values.each do |x|
      next_numeral = x.get_exploded
      unless next_numeral.nil?
        other_numerals[next_numeral.numeral].count += next_numeral.count
      end
    end

    # 2. catenate the values
    catenated = self_numerals
    other.numerals.each do |key, value|
      catenated[key].count += value.count
    end

    # 3. sort the symbols largest <= left
    combined_numerals = catenated.sort_by { |k, v| v.order }
    # sorted_numerals = order_numerals(catenated)
    # 4. start at right end and combine any of the same symbols
    #    that can be combined into a larger one
    catenated.values.sort_by { |x| x.order }.reverse_each do |v|
      next_numeral = v.get_next
      unless next_numeral.nil?
        catenated[next_numeral.numeral] += count
      end
    end
    # combined = replace_with_larger(sorted_numerals)
    # 5. substitute any subtractives
    catenated.values.sort_by { |x| x.order }.reverse_each do |v|
      # Special case I combines with itself 4 times to get IV
      if v.numeral == 'I'
        total_ivs = v.count / 4
        if total_ivs >= 1
          v.count -= total_ivs * 4
          catenated['IV'].count += total_ivs
        end
      else
        subtractive = v.get_subtractive
        unless subtractive.nil?
          second_subtractive = catenated[subtractive]
          total_combination = [v.count, second_subtractive.count].min
          if total_combination >= 1
            catenated[v.get_subtractive_combination].count += total_combination
            v.count -= total_combination
            second_subtractive.count -= total_combination
          end
        end
      end
    end

    # unexploded = order_numerals(unexplode(combined))
    return RomanNumeral.new catenated.values.select { |x| x.count >= 1 }.sort_by { |x| x.order }.join
  end

  def to_i
    @numerals.values.map(&:to_i).reduce(&:+)
  end

  def to_s
    return @numerals.values.select { |x| x.count > 0 }.sort_by { |x| x.order }.join
  end
end