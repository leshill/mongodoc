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
  attr_accessor :documents

  def initialize
    MongoDoc::Connection.name = 'mongo_doc_object_test'
    self.collection = MongoDoc::Collection.new 'people'
    collection.drop
  end

  def generate(count)
    self.documents = []
    count.times do |i|
      person = Person.new(:birth_date => Date.new(1970, 1, 1))
      name = Name.new(:given => "James #{i}", :family => "Kirk", :middle => "Tiberius")
      address = Address.new(:street => "1 Starfleet Command Way", :city => "San Francisco", :state => "CA", :post_code => "94133", :type => "Work")
      phone = Phone.new(:country_code => 1, :number => "415-555-1212", :type => "Mobile")
      person.name = name
      person.address = address
      person.phones << phone

      documents << person
    end
  end

  def writes(count)
    count.times do |i|
      documents[i].save
    end
  end

  def reads(count)
    count.times do |i|
      doc = collection.find_one(documents[i]._id)
      raise 'Not found' unless doc.name.given == documents[i].name.given
    end
  end

  def query_all
    collection.find.each do |doc|
      given_name = doc.name.given
    end
  end
end
