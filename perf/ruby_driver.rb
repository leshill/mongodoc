require "rubygems"
require "ruby-prof"
require "mongo_doc"

class RubyDriver
  attr_accessor :collection

  def initialize
    MongoDoc::Connection.name = 'ruby_driver_test'
    self.collection = MongoDoc::Connection.database.collection 'people'
    collection.drop
  end

  def perform
    person = {:birth_date => Date.new(1970, 1, 1).to_bson, :phones => []}
    name = {:given => "James", :family => "Kirk", :middle => "Tiberius"}
    address = {:street => "1 Starfleet Command Way", :city => "San Francisco", :state => "CA", :post_code => "94133", :type => "Work"}
    phone = {:country_code => 1, :number => "415-555-1212", :type => "Mobile"}
    person[:name] = name
    person[:address] = address
    person[:phones] << phone
    collection.save(person)
  end
end
