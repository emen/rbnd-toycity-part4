require_relative 'find_by'
require_relative 'errors'
require 'csv'
require 'pp'

class Udacidata
  FILE = File.dirname(__FILE__) + "/../data/data.csv"

  def self.create(options = {})
    new(options).tap do |obj|
      CSV.open(FILE, 'ab') do |row|
        row << CSV::Row.new(headers, headers.map{ |header| obj.send(header.to_sym) }) 
      end
    end
  end

  def self.destroy(n)
    # refresh all before deleting
    all
    find(n).tap do |obj|
      @@all.delete(obj)
      save
    end
  end

  def self.save
    headers
    CSV.open(FILE, 'wb', headers: true) do |row|
      row << headers
      @@all.each do |obj|
        row << CSV::Row.new(headers, headers.map{ |header| obj.send(header.to_sym) }) 
      end
    end
  end

  def self.all
    @@all = CSV.foreach(FILE, headers: true, header_converters: :symbol).to_a.map do |row|
      new(row.to_hash)
    end
  end

  def self.first(n=1)
    n == 1 ? all.first : all.first(n)
  end

  def self.last(n=1)
    n == 1 ? all.last : all.last(n)
  end

  def self.find(the_id)
    all.find{ |obj| obj.id == the_id }
  end

  def self.where(options={})
    all.select do |obj|
      options.all? { |k, v| obj.send(k) == v}
    end
  end

  def self.headers
    @@headers ||= CSV.foreach(FILE).first
  end

  def self.method_missing(method_sym, *arguments, &block)
    if method_sym.to_s =~ /find_by_/
      self.headers.each do |header|
        class_eval %{
          def self.find_by_#{header}(value)
            all.find { |obj| obj.#{header.to_sym} == value }
          end
        }
      end
      self.send(method_sym, *arguments)
    else
      super
    end
  end

end
