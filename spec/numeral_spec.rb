require 'rspec'
require 'numeral'

describe Numeral do
  describe '.<' do
    it 'should return that I is less than V' do
      first = Numeral.new 'I'
      second = Numeral.new 'V'
      expect(first < second).to eql(true)
    end
    it 'should return that IV is less than C' do
      first = Numeral.new 'IV'
      second = Numeral.new 'C'
      expect(first < second).to eql(true)
    end
    it 'should return that D is not less than C' do
      first = Numeral.new 'D'
      second = Numeral.new 'C'
      expect(first < second).to eql(false)
    end
    it 'should return that M is not less than X' do
      first = Numeral.new 'M'
      second = Numeral.new 'X'
      expect(first < second).to eql(false)
    end
  end
  describe '.>' do
    it 'should return that V is greater than IV' do
      first = Numeral.new 'V'
      second = Numeral.new 'IV'
      expect(first > second).to eql(true)
    end
    it 'should return that L is greater than X' do
      first = Numeral.new 'L'
      second = Numeral.new 'X'
      expect(first > second).to eql(true)
    end
    it 'should return that X is not greater than C' do
      first = Numeral.new 'X'
      second = Numeral.new 'C'
      expect(first > second).to eql(false)
    end
    it 'should return that CD is not greater than D' do
      first = Numeral.new 'CD'
      second = Numeral.new 'D'
      expect(first > second).to eql(false)
    end
  end

  describe '.get_exploded_numerals' do
    it 'should return 4 I if IV' do
      numerals = Numeral.new('IV').get_exploded
      expect(numerals.count(Numeral.new('I'))).to eql(4)
      expect(numerals.length).to eql(4)
    end
    it 'should return 1 V if V' do
      numerals = Numeral.new('V').get_exploded
      expect(numerals.count(Numeral.new('V'))).to eql(1)
      expect(numerals.length).to eql(1)
    end
    it 'should return 1 V and 4 I if IX' do
      numerals = Numeral.new('IX').get_exploded
      expect(numerals.count(Numeral.new('V'))).to eql(1)
      expect(numerals.count(Numeral.new('I'))).to eql(4)
      expect(numerals.length).to eql(5)
      end
    it 'should return 1 D and 4 C if CM' do
      numerals = Numeral.new('CM').get_exploded
      expect(numerals.count(Numeral.new('D'))).to eql(1)
      expect(numerals.count(Numeral.new('C'))).to eql(4)
      expect(numerals.length).to eql(5)
    end
  end
end