require_relative '../modules/currency_formatter'

RSpec.describe CurrencyFormatter do
  describe '.format_currency' do
    it 'formats a large integer correctly' do
      expect(CurrencyFormatter.format_currency(84523687)).to eq '845,236.87'
    end

    it 'formats a small integer correctly' do
      expect(CurrencyFormatter.format_currency(1499)).to eq '14.99'
    end

    it 'formats an integer without leading digits correctly' do
      expect(CurrencyFormatter.format_currency(45)).to eq '0.45'
    end

    it 'adds commas appropriately for very large numbers' do
      expect(CurrencyFormatter.format_currency(123456789)).to eq '1,234,567.89'
    end
  end
end
