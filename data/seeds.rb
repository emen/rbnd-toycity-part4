require 'faker'

# This file contains code that populates the database with
# fake data for testing purposes

def db_seed
  data_path = File.dirname(__FILE__) + "/data.csv"
  CSV.open(data_path, "ab") do |csv|
    0.upto(9).each do |index|
      csv << [index, Faker::Company.name, Faker::Commerce.product_name, Faker::Commerce.price]
    end
  end
end
