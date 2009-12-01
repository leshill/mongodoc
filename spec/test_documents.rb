class Address < MongoDoc::Document
  key :street
  key :city
  key :state
  key :zip_code
end

class Place < MongoDoc::Document
  key :name
  has_one :address
end

class Location < MongoDoc::Document
  has_one :address
  key :website
end

class WifiAccessible < Location
  key :network_name
end

class WebSite
  attr_accessor :url
end

module Automobile
  class Ariel < MongoDoc::Document
    key :name
  end
end

class Contact < MongoDoc::Document
  key :name
  has_many :addresses
end