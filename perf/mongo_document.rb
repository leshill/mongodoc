require "benchmark"
require "ruby-prof"
require "mongo_doc"

class Person
  include MongoDoc::Document

  attr_accessor :birth_date, :type => Date

  embed :name
  embed :address
  embed_many :phones
end

class Name
  include MongoDoc::Document

  attr_accessor :given
  attr_accessor :family
  attr_accessor :middle
end

class Address
  include MongoDoc::Document

  attr_accessor :street
  attr_accessor :city
  attr_accessor :state
  attr_accessor :post_code
  attr_accessor :type
end

class Phone
  include MongoDoc::Document

  attr_accessor :country_code
  attr_accessor :number
  attr_accessor :type
end

class MongoDocument
  attr_accessor :collection

  def initialize
    MongoDoc::Connection.name = 'mongo_doc_object_test'
    self.collection = MongoDoc::Collection.new 'people'
    collection.drop
  end

  def perform
    person = Person.new(:birth_date => Date.new(1970, 1, 1))
    name = Name.new(:given => "James", :family => "Kirk", :middle => "Tiberius")
    address = Address.new(:street => "1 Starfleet Command Way", :city => "San Francisco", :state => "CA", :post_code => "94133", :type => "Work")
    phone = Phone.new(:country_code => 1, :number => "415-555-1212", :type => "Mobile")
    person.name = name
    person.address = address
    person.phones << phone
    person.save
  end
end
