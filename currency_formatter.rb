module CurrencyFormatter
  def self.format_currency(amount_in_pounds)
    amount_str = amount_in_pounds.to_s.rjust(3, '0')
    formatted_amount = amount_str.insert(-3, '.')
    formatted_amount.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
end
