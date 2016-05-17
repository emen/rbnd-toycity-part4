require_relative 'find_by'
require_relative 'errors'
require 'csv'
require 'pp'

class Udacidata

  # TODO: should be config
  FILE = File.dirname(__FILE__) + "/../data/data.csv"

  #---
  # constructor
  #---
  def initialize(opts={})
    headers = self.class.headers
    get_last_id
    if opts[:id]
      opts[:id] = opts[:id].to_i
    else
      opts[:id] = @@count_class_instances
      auto_increment
    end
    @data = CSV::Row.new(headers, headers.map { |header| opts.fetch(header, nil) })
    self.class.header_reader *headers
  end

  def update(opts={})
    opts.each { |header, value| @data[header] = value }
    self.class.save
    self
  end

  def to_s
    @data.each.map { |header, value| "#{header}: #{value}"}.join(", ")
  end

  #---
  # class methods
  #---
  def self.create(options = {})
    new(options).tap do |obj|
      CSV.open(FILE, 'ab') do |row|
        row << CSV::Row.new(headers, headers.map{ |header| obj.send(header) }) 
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
        row << CSV::Row.new(headers, headers.map{ |header| obj.send(header) }) 
      end
    end
  end

  def self.all
    @@all = CSV.foreach(FILE, headers: true, header_converters: :symbol, converters: :all).to_a.map do |row|
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
    all.find{ |obj| obj.id == the_id } ||
      raise(ProductNotFoundError, "Can't find product with id '#{the_id}'")
  end

  def self.where(options={})
    all.select do |obj|
      options.all? { |k, v| obj.send(k) == v}
    end
  end

  def self.headers
    @@headers ||= CSV.foreach(FILE).first.map(&:to_sym)
  end

  def self.method_missing(method_sym, *arguments, &block)
    # lazy create find_by_* methods
    # headers may not be available when this file is read and parsed
    if method_sym.to_s =~ /find_by_/
      self.create_finder_methods *self.headers
      self.send(method_sym, *arguments)
    else
      super
    end
  end

  private
  # Reads the last line of the data file, and gets the id if one exists
  # If it exists, increment and use this value
  # Otherwise, use 0 as starting ID number
  def get_last_id
    file = File.dirname(__FILE__) + "/../data/data.csv"
    last_id = File.exist?(file) ? CSV.read(file).last[0].to_i + 1 : nil
    @@count_class_instances = last_id || 0
  end

  def auto_increment
    @@count_class_instances += 1
  end

  private_class_method
  def self.header_reader(*headers)
    headers.each do |header|
      define_method(header) do
        @data[header]
      end
    end
  end
end
