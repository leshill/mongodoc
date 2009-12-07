class Address < MongoDoc::Document
  key :street
  key :city
  key :state
  key :zip_code
end

class Place < MongoDoc::Document
  key :name
  key :type
  has_one :address
end

class Contact < MongoDoc::Document
  key :name
  key :type
  key :interests
  has_many :addresses
end
