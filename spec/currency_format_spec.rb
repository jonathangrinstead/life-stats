require_relative '../stats_automation.rb'

describe '#format_currency' do
  it 'formats an integer correctly' do
    expect(format_currency(123456)).to eq '1,234.56'
    expect(format_currency(84523687)).to eq '845,236.87'
    expect(format_currency(1499)).to eq '14.99'
  end
end
