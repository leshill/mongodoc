class Address
  include MongoDoc::Document

  key :street
  key :city
  key :state
  key :zip_code
end

class Place
  include MongoDoc::Document

  key :name
  key :type
  has_one :address
end

class Contact
  include MongoDoc::Document

  key :name
  key :type
  key :note
  key :interests
  has_many :addresses

  scope :rubyists, any_in(:interests => ['ruby'])
  scope :contract_work, any_in(:interests => ['contract work'])
  scope :in_state, lambda {|state| where('addresses.state' => state)}
end

class Event
  include MongoDoc::Document

  key :name
  key :venue
  key :date, :type => Date
end
