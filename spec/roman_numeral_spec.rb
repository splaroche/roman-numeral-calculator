require 'rspec'
require 'roman_numeral'

describe RomanNumeral do
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

  describe '.+' do
    context 'given V + I' do
      it 'should return VI' do
        numeral1 = RomanNumeral.new 'V'
        numeral2 = RomanNumeral.new 'I'

        added_numeral = numeral1 + numeral2
        expect(added_numeral.to_s).to eql('VI')
      end
    end

    context 'given XI + V' do
      it 'should return XVI' do
        numeral1 = RomanNumeral.new 'XI'
        numeral2 = RomanNumeral.new 'V'

        added_numeral = numeral1 + numeral2
        expect(added_numeral.to_s).to eql('XVI')
      end
    end

    context 'given XVI + III' do
      it 'should return XIX' do
        numeral1 = RomanNumeral.new 'XVI'
        numeral2 = RomanNumeral.new 'III'

        added_numeral = numeral1 + numeral2
        expect(added_numeral.to_s).to eql('XIX')
      end
    end

    context 'given CXLIV + DCCCLV' do
      it 'should return CMXCIX' do
        numeral1 = RomanNumeral.new 'CXLIV'
        numeral2 = RomanNumeral.new 'DCCCLV'

        added_numeral = numeral1 + numeral2
        expect(added_numeral.to_s).to eql('CMXCIX')
      end
    end

    context 'given CCCCCCCCCXXIIV + VI' do
      it 'should return CMXXXI' do
        numeral1 = RomanNumeral.new 'CCCCCCCCCXXIIV'
        numeral2 = RomanNumeral.new 'VI'

        added_numeral = numeral1 + numeral2
        expect(added_numeral.to_s).to eql('CMXXXI')
      end
    end
  end
  describe '.-' do
    context 'given LXVIII + XII' do
      it 'should return LVI' do
        numeral1 = RomanNumeral.new 'LXVIII'
        numeral2 = RomanNumeral.new 'XII'

        added_numeral = numeral1 - numeral2
        expect(added_numeral.to_s).to eql('LVI')
      end
    end

    context 'given CXXIX + XLIII' do
      it 'should return LXXXVI' do
        numeral1 = RomanNumeral.new 'CXXIX'
        numeral2 = RomanNumeral.new 'XLIII'

        added_numeral = numeral1 - numeral2
        expect(added_numeral.to_s).to eql('LXXXVI')
      end
    end

  end
end