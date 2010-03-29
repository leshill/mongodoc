require "rubygems"
require "ruby-prof"
require "mongo_doc"

class Person
  attr_accessor :address, :birth_date, :name, :phones
end

class Name
  attr_accessor :family, :given, :middle
end

class Address
  attr_accessor :city, :post_code, :state, :street, :type
end

class Phone
  attr_accessor :country_code, :number, :type
end

class MongoDocObject
  attr_accessor :collection

  def initialize
    MongoDoc::Connection.name = 'mongo_doc_object_test'
    self.collection = MongoDoc::Collection.new 'people'
    collection.drop
  end

  def perform
    person = Person.new
    person.birth_date = Date.new(1970, 1, 1)
    person.phones = []

    name = Name.new
    name.given = "James"
    name.family = "Kirk"
    name.middle = "Tiberius"

    address = Address.new
    address.street = "1 Starfleet Command Way"
    address.city = "San Francisco"
    address.state = "CA"
    address.post_code = "94133"
    address.type = "Work"

    phone = Phone.new
    phone.country_code = 1
    phone.number = "415-555-1212"
    phone.type = "Mobile"

    person.name = name
    person.address = address
    person.phones << phone

    collection.save(person)
  end
end
