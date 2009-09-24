class Address < MongoDoc::Base
  key :street
  key :city
  key :state
  key :zip_code
end

class Location < MongoDoc::Base
  key :address
  key :website
end

class WifiAccessible < Location
  key :network_name
end

class WebSite
  attr_accessor :url
end
