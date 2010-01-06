require "benchmark"
require "ruby-prof"
require "mongodoc"

class Person < MongoDoc::Document
  key :birth_date
  has_one :name
  has_one :address
  has_many :phones
end

class Name < MongoDoc::Document
  key :given
  key :family
  key :middle
end

class Address < MongoDoc::Document
  key :street
  key :city
  key :state
  key :post_code
  key :type
end

class Phone < MongoDoc::Document
  key :country_code
  key :number
  key :type
end

class MongoDocRunner
  def self.benchmark
    MongoDoc.connect_to_database('mongodoc_perf_test')
    MongoDoc.database.collection('people').drop

    puts "Starting benchmark..."

    10.times do |n|
      person = Person.new(:birth_date => Date.new(1970, 1, 1))
      name = Name.new(:given => "James", :family => "Kirk", :middle => "Tiberius")
      address = Address.new(:street => "1 Starfleet Command Way", :city => "San Francisco", :state => "CA", :post_code => "94133", :type => "Work")
      phone = Phone.new(:country_code => 1, :number => "415-555-1212", :type => "Mobile")
      person.name = name
      person.address = address
      person.phones << phone
      person.save
    end

    Benchmark.bm do |bm|
      bm.report('MongoDoc') do
        10000.times do |n|
          person = Person.new(:birth_date => Date.new(1970, 1, 1))
          name = Name.new(:given => "James", :family => "Kirk", :middle => "Tiberius")
          address = Address.new(:street => "1 Starfleet Command Way", :city => "San Francisco", :state => "CA", :post_code => "94133", :type => "Work")
          phone = Phone.new(:country_code => 1, :number => "415-555-1212", :type => "Mobile")
          person.name = name
          person.address = address
          person.phones << phone
          person.save
        end
      end
    end

  end

  def self.profile
    MongoDoc.connect_to_database('mongodoc_perf_test')
    MongoDoc.database.collection('people').drop

    RubyProf.start

    puts "Starting profiler..."

    1000.times do |n|
      person = Person.new(:birth_date => Date.new(1970, 1, 1))
      name = Name.new(:given => "James", :family => "Kirk", :middle => "Tiberius")
      address = Address.new(:street => "1 Starfleet Command Way", :city => "San Francisco", :state => "CA", :post_code => "94133", :type => "Work")
      phone = Phone.new(:country_code => 1, :number => "415-555-1212", :type => "Mobile")
      person.name = name
      person.address = address
      person.phones << phone
      person.save
    end

    result = RubyProf.stop
    printer = RubyProf::FlatPrinter.new(result)
    printer.print(STDOUT, 0)
  end
end
