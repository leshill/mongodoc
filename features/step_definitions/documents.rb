class Address
  include MongoDoc::Document

  attr_accessor :street
  attr_accessor :city
  attr_accessor :state
  attr_accessor :zip_code
end

class Place
  include MongoDoc::Document

  attr_accessor :name
  attr_accessor :type
  has_one :address
end

class Contact
  include MongoDoc::Document

  attr_accessor :name
  attr_accessor :type
  attr_accessor :note
  attr_accessor :interests
  has_many :addresses

  scope :rubyists, any_in(:interests => ['ruby'])
  scope :contract_work, any_in(:interests => ['contract work'])
  scope :in_state, lambda {|state| where('addresses.state' => state)}
end

class Event
  include MongoDoc::Document

  attr_accessor :name
  attr_accessor :venue
  attr_accessor :date, :type => Date
end
