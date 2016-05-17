module Analyzable

  def self.average_price(products)
    (products.map(&:price).inject(&:+).to_f / products.size).round(2)
  end

  def self.print_report(products)
    leading_space = ' ' * 4
    ''.tap do |report|
      report << "Average Price: %.2f\n" % average_price(products)

      report << "Inventory by Brand:\n"
      count_by_brand(products).each do |brand, total|
        report << "#{leading_space}- #{brand}: #{total}\n"
      end

      report << "Inventory by Name:\n"
      count_by_name(products).each do |name, total|
        report << "#{leading_space}- #{name}: #{total}\n"
      end
    end
  end

  def self.count_by_brand(products)
    products.group_by(&:brand).map { |brand, prods| [brand, prods.size] }.to_h
  end

  def self.count_by_name(products)
    products.group_by(&:name).map  { |name, prods| [name, prods.size] }.to_h
  end

end
