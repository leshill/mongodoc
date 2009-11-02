class Address < MongoDoc::Base
  key :street
  key :city
  key :state
  key :zip_code
end

class Place < MongoDoc::Base
  key :name
  has_one :address
end

class Location < MongoDoc::Base
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
  class Ariel < MongoDoc::Base
    key :name
  end
end

class Contact < MongoDoc::Base
  key :name
  has_many :addresses
end