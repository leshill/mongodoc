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
  key :interests
  has_many :addresses

  named_scope :rubyists, :in => {:interests => ['ruby']}
  named_scope :contract_work, :in => {:interests => ['contract work']}
  named_scope :in_state, lambda {|state| { :where => {'addresses.state' => state}}}
end
