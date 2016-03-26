class Numeral
  include Comparable

  class Node
    attr_accessor :value, :children

    def initialize(value, children: [])
      @value = value
      @children = children
    end

    def to_s
      @value.to_s
    end
  end

# The order of writing will be the reverse of this list
  @@ORDER_OF_PRECEDENCE = [
      'I',
      'IV',
      'V',
      'IX',
      'X',
      'XL',
      'L',
      'XC',
      'C',
      'CD',
      'D',
      'CM',
      'M'
  ]

  @@EXPLODING_NUMERALS = [
      'IV',
      'IX',
      'XL',
      'XC',
      'CD',
      'CM',
  ]

  @@NEXT_NUMERALS = {
      'I' => 'V',
      'V' => 'X',
      'X' => 'L',
      'L' => 'C',
      'C' => 'D',
      'D' => 'M'
  }


  @@SOLO_SUBSTITUTIONS = {
      'I' => 'IV',
      'X' => 'XL',
      'C' => 'CD'
  }

  @@DOUBLE_SUBSTITUTIONS = {
      'V' => 'IX',
      'IV' => 'IX',
      'L' => 'XC',
      'XL' => 'XC',
      'D' => 'CM',
      'CD' => 'CM'
  }

  attr_accessor :value, :solo_substitution, :double_substitution, :explodable

  def initialize(numeral)
    @value = numeral
    @tree = nil

    @explodable = @@EXPLODING_NUMERALS.include? numeral
    @next_numeral = @@NEXT_NUMERALS[numeral]

    solo_substitution = @@SOLO_SUBSTITUTIONS[numeral]
    unless solo_substitution.nil?
      solo_substitution = Numeral.new(solo_substitution)
    end
    @solo_substitution = solo_substitution

    double_substitution = @@DOUBLE_SUBSTITUTIONS[numeral]
    unless double_substitution.nil?
      double_substitution = Numeral.new(double_substitution)
    end
    @double_substitution = double_substitution

  end

  def get_exploded
    @tree ||= Numeral.get_tree(@value)
    exploded = []
    if @explodable
      children = @tree.children.map { |x| x.value }
      children.each do |i|
        if i.explodable
          exploded.concat i.get_exploded
        else
          exploded.push i
        end
      end
      return exploded
    end
    return [self]
  end

  def get_next
    next_numeral_tree = Numeral.get_tree(@next_numeral)
    return next_numeral_tree.value, next_numeral_tree.children.length
  end

  def get_second_substitute_part
    substitution_tree = Numeral.get_tree(@double_substitution.value)
    substitutions = substitution_tree.children.map { |x| x.value }.reject! { |x| x.value == @value }.uniq
    return substitutions.first
  end


  def get_subtractive
    @tree ||= Numeral.get_tree(@value)
    return @tree.children.map { |x| x.value }.sort
  end

  def <=>(other)
    self_index = @@ORDER_OF_PRECEDENCE.index(@value)
    other_index = @@ORDER_OF_PRECEDENCE.index(other.value)
    return self_index <=> other_index
  end

  def eql?(other)
    @value == other.value
  end

  def hash
    @value.hash
  end

  def to_s
    @value
  end

# Class methods
  def self.get_tree(numeral)
    i = Node.new(Numeral.new('I'))
    iv = Node.new(Numeral.new('IV'), children: [i] * 4)
    v = Node.new(Numeral.new('V'), children: [i] * 5)
    ix = Node.new(Numeral.new('IX'), children: [iv] + [v])
    x = Node.new(Numeral.new('X'), children: [v] * 2)
    xl = Node.new(Numeral.new('XL'), children: [x] * 4)
    l = Node.new(Numeral.new('L'), children: [x] * 5)
    xc = Node.new(Numeral.new('XC'), children: [xl] + [l])
    c = Node.new(Numeral.new('C'), children: [l] * 2)
    cd = Node.new(Numeral.new('CD'), children: [c] * 4)
    d = Node.new(Numeral.new('D'), children: [c] * 5)
    cm = Node.new(Numeral.new('CM'), children: [cd] + [d])
    m = Node.new(Numeral.new('M'), children: [d] * 2)

    case numeral
      when 'I'
        return i
      when 'IV'
        return iv
      when 'V'
        return v
      when 'IX'
        return ix
      when 'X'
        return x
      when 'XL'
        return xl
      when 'L'
        return l
      when 'XC'
        return xc
      when 'C'
        return c
      when 'CD'
        return cd
      when 'D'
        return d
      when 'CM'
        return cm
      when 'M'
        return m
      else
    end
    return Node.new(nil)

  end

  def self.ORDER_OF_PRECEDENCE
    return @@ORDER_OF_PRECEDENCE
  end

end

