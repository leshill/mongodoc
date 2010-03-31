require "rubygems"
require "ruby-prof"
require "mongo_doc"

class RubyDriver
  attr_accessor :collection
  attr_accessor :objects
  attr_accessor :ids

  def initialize
    MongoDoc::Connection.name = 'ruby_driver_test'
    self.collection = MongoDoc::Connection.database.collection 'people'
    collection.drop
  end

  def generate(count)
    self.objects = []
    self.ids = []
    count.times do |i|
      person = {:birth_date => Date.new(1970, 1, 1).to_bson, :phones => []}
      name = {:given => "James #{i}", :family => "Kirk", :middle => "Tiberius"}
      address = {:street => "1 Starfleet Command Way", :city => "San Francisco", :state => "CA", :post_code => "94133", :type => "Work"}
      phone = {:country_code => 1, :number => "415-555-1212", :type => "Mobile"}
      person[:name] = name
      person[:address] = address
      person[:phones] << phone
      objects << person
    end
  end

  def writes(count)
    count.times do |i|
      ids[i] = collection.save(objects[i])
    end
  end

  def reads(count)
    count.times do |i|
      obj = collection.find_one(ids[i])
      raise 'Not found' unless obj and obj['name']['given'] == objects[i][:name][:given]
    end
  end
end
