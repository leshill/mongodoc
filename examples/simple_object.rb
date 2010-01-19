require 'mongodoc'

class Contact
  attr_accessor :name, :addresses, :interests
end

class Address
  attr_accessor :street, :city, :state, :zip, :phone_number
end

MongoDoc.connect_to_database 'test'

collection = MongoDoc::Collection.new('contacts')
collection.drop

contact = Contact.new
contact.name = 'Hashrocket'
contact.interests = ['ruby', 'rails', 'agile']

address = Address.new
address.street = '320 First Street North, #712'
address.city = 'Jacksonville Beach'
address.state = 'FL'
address.zip = '32250'
address.phone_number = '877 885 8846'
contact.addresses = [address]

collection.save(contact)

results = collection.find('addresses.state' => 'FL')
hashrocket = results.to_a.find {|contact| contact.name == 'Hashrocket'}
puts hashrocket.addresses.first.phone_number
