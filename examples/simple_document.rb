require 'mongo_doc'

class Address
  include MongoDoc::Document

  attr_accessor :street
  attr_accessor :city
  attr_accessor :state
  attr_accessor :zip_code
  attr_accessor :phone_number
end

class Contact
  include MongoDoc::Document

  attr_accessor :name
  attr_accessor :interests
  embed_many :addresses

  scope :in_state, lambda {|state| where('addresses.state' => state)}
end

Contact.collection.drop

contact = Contact.new(:name => 'Hashrocket', :interests => ['ruby', 'rails', 'agile'])
contact.addresses << Address.new(:street => '320 1st Street North, #712', :city => 'Jacksonville Beach', :state => 'FL', :zip_code => '32250', :phone_number => '877 885 8846')
contact.save

# Finders
Contact.find_all.each {|c| puts c.name}
puts contact.to_param
puts Contact.find_one(contact.to_param).addresses.first.street
Contact.find(contact.to_param).each {|c| puts c.name}

hashrocket_in_fl = Contact.in_state('FL').where(:name => /rocket/)

hashrocket_address = hashrocket_in_fl.first.addresses.first
hashrocket_address.update_attributes(:street => '320 First Street North, #712')

puts Contact.where(:name => 'Hashrocket').first.addresses.first.street

# Criteria behave like new AR3 AREL queries
hr = Contact.where(:name => 'Hashrocket')
hr_in = hr.where('addresses.state' => 'IN')
puts hr.count
puts hr_in.count
