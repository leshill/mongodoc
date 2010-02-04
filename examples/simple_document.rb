require 'mongodoc'

class Address
  include MongoDoc::Document

  key :street
  key :city
  key :state
  key :zip_code
  key :phone_number
end

class Contact
  include MongoDoc::Document

  key :name
  key :interests
  has_many :addresses

  named_scope :in_state, lambda {|state| {:where => {'addresses.state' => state}}}
end

Contact.collection.drop

contact = Contact.new(:name => 'Hashrocket', :interests => ['ruby', 'rails', 'agile'])
contact.addresses << Address.new(:street => '320 1st Street North, #712', :city => 'Jacksonville Beach', :state => 'FL', :zip_code => '32250', :phone_number => '877 885 8846')
contact.save

hashrocket = Contact.in_state('FL').find {|contact| contact.name == 'Hashrocket'}

hashrocket_address = hashrocket.addresses.first
hashrocket_address.update_attributes(:street => '320 First Street North, #712')

puts Contact.find_one(:where => {:name => 'Hashrocket'}).addresses.first.street
