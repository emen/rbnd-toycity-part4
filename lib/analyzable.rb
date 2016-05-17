module Analyzable

  def self.average_price(products)
    (products.map(&:price).inject(&:+).to_f / products.size).round(2)
  end

  def self.print_report(products)
    ''
  end

  def self.count_by_brand(products)
    products.group_by(&:brand).map { |brand, prods| [brand, prods.size] }.to_h
  end

  def self.count_by_name(products)
    products.group_by(&:name).map  { |name, prods| [name, prods.size] }.to_h
  end

end
