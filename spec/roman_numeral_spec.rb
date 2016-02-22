require 'rspec'
require 'roman_numeral'

describe RomanNumeral do
  describe 'new' do
    context "given I" do
      it 'should convert to 1' do
        numeral = RomanNumeral.new 'I'

        expect(numeral.to_i).to eql(1)
      end
    end
    context 'given V' do
      it 'should convert to 5' do
        numeral = RomanNumeral.new 'V'

        expect(numeral.to_i).to eql(5)
      end
    end
    context 'give IV' do
      it 'should convert to 4' do
        numeral = RomanNumeral.new 'IV'

        expect(numeral.to_i).to eql(4)
      end
    end
    context 'given CM' do
      it 'should convert to 900' do
        numeral = RomanNumeral.new 'CM'

        expect(numeral.to_i).to eql(900)
      end
    end
    context 'given MCMVI' do
      it 'should convert to 1906' do
        numeral = RomanNumeral.new 'MCMVI'

        expect(numeral.to_i).to eql(1906)
      end
    end
    context 'give MMDCCXVI' do
      it 'should convert to 2716' do
        numeral = RomanNumeral.new 'MMDCCXVI'

        expect(numeral.to_i).to eql(2716)
      end
    end
  end

  describe '.to_s' do
    context 'given XD' do
      it 'should return DX' do
        numeral = RomanNumeral.new 'XD'
        expect(numeral.to_s).to eql('DX')
      end
      end
    context 'given XDCDLIVX' do
      it 'should return DCDLXXIV' do
        numeral = RomanNumeral.new 'XDCDLIVX'
        expect(numeral.to_s).to eql('DCDLXXIV')
      end
    end
  end
end