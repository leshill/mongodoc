require 'mongo_doc'

class Contact
  attr_accessor :name, :addresses, :interests
end

class Address
  attr_accessor :street, :city, :state, :zip, :phone_number
end

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

in_florida = collection.where('addresses.state' => 'FL')
puts in_florida.first.addresses.first.phone_number
rocket_oid_names = collection.where('name' => /rocket/)
puts rocket_oid_names.first.addresses.first.phone_number
interested_in_ruby = collection.in('interests' => ['ruby'])
puts interested_in_ruby.first.addresses.first.phone_number

