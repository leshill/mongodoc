require "rubygems"
require "ruby-prof"
require "mongodoc"

class RubyDriverRunner
  def self.benchmark
    MongoDoc.connect_to_database('mongodoc_perf_test')
    collection = MongoDoc.database.collection('people')
    collection.drop

    puts "Starting benchmark..."

    10.times do |n|
      person = {:birth_date => Date.new(1970, 1, 1).to_bson, :phones => []}
      name = {:given => "James", :family => "Kirk", :middle => "Tiberius"}
      address = {:street => "1 Starfleet Command Way", :city => "San Francisco", :state => "CA", :post_code => "94133", :type => "Work"}
      phone = {:country_code => 1, :number => "415-555-1212", :type => "Mobile"}
      person[:name] = name
      person[:address] = address
      person[:phones] << phone
      collection.save(person)
    end

    Benchmark.bm do |bm|
      bm.report('Driver') do
        10000.times do |n|
          person = {:birth_date => Date.new(1970, 1, 1).to_bson, :phones => []}
          name = {:given => "James", :family => "Kirk", :middle => "Tiberius"}
          address = {:street => "1 Starfleet Command Way", :city => "San Francisco", :state => "CA", :post_code => "94133", :type => "Work"}
          phone = {:country_code => 1, :number => "415-555-1212", :type => "Mobile"}
          person[:name] = name
          person[:address] = address
          person[:phones] << phone
          collection.save(person)
        end
      end
    end
  end

  def self.profile
    MongoDoc.connect_to_database('mongodoc_perf_test')
    collection = MongoDoc.database.collection('people')
    collection.drop

    RubyProf.start

    puts "Starting profiler..."

    1000.times do |n|
      person = {:birth_date => Date.new(1970, 1, 1), :phones => []}
      name = {:given => "James", :family => "Kirk", :middle => "Tiberius"}
      address = { :street => "1 Starfleet Command Way", :city => "San Francisco", :state => "CA", :post_code => "94133", :type => "Work"}
      phone = {:country_code => 1, :number => "415-555-1212", :type => "Mobile"}
      person[:name] = name
      person[:address] = address
      person[:phones] << phone
      collection.insert(person)
    end

    result = RubyProf.stop
    printer = RubyProf::FlatPrinter.new(result)
    printer.print(STDOUT, 0)
  end
end
