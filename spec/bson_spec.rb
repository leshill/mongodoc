require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "BSON for Mongo (BSON)" do
  describe "#decode" do
    it "just returns the json if the :raw_json option is used" do
      hash = {}
      MongoDoc::BSON.should_not_receive(:bson_create)
      MongoDoc::BSON.decode(hash, :raw_json => true).should == hash
    end

    it "calls bson_create if parameter is a hash" do
      hash = {}
      options = {:option => true}
      MongoDoc::BSON.should_receive(:bson_create).with(hash, options)
      MongoDoc::BSON.decode(hash, options)
    end

    it "if parameter is an array, it calls array_create" do
      array = []
      options = {:option => true}
      MongoDoc::BSON.should_receive(:array_create).with(array, options)
      MongoDoc::BSON.decode(array, options)
    end
    
    it "returns the json value as is if the parameter is not a hash or array" do
      ["", 1, 1.5, true, false, nil].each do |type_value|
        MongoDoc::BSON.decode(type_value).should == type_value
      end
    end
  end

  describe "#array_create" do
    it "calls decode for each element" do
      first = 1
      array = [first]
      options = {:option => true}
      MongoDoc::BSON.should_receive(:decode).with(first, options)
      MongoDoc::BSON.array_create(array, options)
    end
    
    it "just returns the array if the :raw_json option is used" do
      hash = {'key' => 'value', MongoDoc::BSON::CLASS_KEY => 'Date'}
      array = [hash]
      MongoDoc::BSON.should_not_receive(:decode)
      MongoDoc::BSON.array_create(array, :raw_json => true).should == array
    end
  end
  
  describe "#bson_create" do
    it "leaves a simple hash intact" do
      hash = {}
      MongoDoc::BSON.bson_create(hash).should == hash
    end
    
    it "a class hash extracts the class, and calls class.bson_create" do
      base_hash = {'key' => 'value'}
      bson_hash = base_hash.merge(MongoDoc::BSON::CLASS_KEY => 'Date')
      Date.should_receive(:bson_create).with(base_hash, {})
      MongoDoc::BSON.bson_create(bson_hash)
    end
    
    it "ignores a class hash when the :raw_json option is used" do
      hash = {'key' => 'value', MongoDoc::BSON::CLASS_KEY => 'Date'}
      MongoDoc::BSON.bson_create(hash, :raw_json => true).should == hash
    end
  end
  
  describe "Hash" do
    it "#to_bson returns the hash" do
      hash = {'key' => 1}
      hash.to_bson.should == hash
    end
    
    it "#to_bson returns the hash with symbol keys as strings" do
      {:key => 1}.to_bson.should == {"key" => 1}
    end

    it "decodes to a hash" do
      hash = {'key' => 1}
      MongoDoc::BSON.decode(hash.to_bson).should == hash
    end
    
    it "decodes the values of the hash" do
      hash = {'key' => {'subkey' => Date.today}}
      MongoDoc::BSON.decode(hash.to_bson).should == hash
    end
  end
  
  describe "Array" do
    it "#to_bson returns the array" do
      array = ['string', 1]
      array.to_bson.should == array
    end
    
    it "#to_bson iterates over its elements" do
      array = []
      array.should_receive(:map)
      array.to_bson
    end
    
    it "decodes to an array" do
      array = ['string', 1]
      MongoDoc::BSON.decode(array.to_bson).should == array
    end
  end
  
  describe "Extensions to core classes" do
    it "#to_bson for objects that are BSON native return themselves" do
      [true, false, nil, 1.0, 1, /regexp/, 'string', :symbol, Time.now].each do |native|
        native.to_bson.should == native
      end
    end
    
    it "objects that are BSON native decode to themselves" do
      [true, false, nil, 1.0, 1, /regexp/, 'string', :symbol, Time.now].each do |native|
        hash = {'native' => native}
        MongoDoc::BSON.decode(hash.to_bson).should == hash
      end
    end
    
    it "Date#to_bson returns a date hash" do
      date = Date.today
      date.to_bson.should == {MongoDoc::BSON::CLASS_KEY => "Date", "dt" => date.strftime, "sg"  => date.respond_to?(:start) ? date.start : date.sg}
    end

    it "roundtrips Date" do
      date = Date.today
      MongoDoc::BSON.decode(date.to_bson).should == date
    end
    
    it "DateTime#to_bson returns a datetime hash" do
      datetime = DateTime.now
      datetime.to_bson.should == {MongoDoc::BSON::CLASS_KEY => "DateTime", "dt" => datetime.strftime, "sg"  => datetime.respond_to?(:start) ? datetime.start : datetime.sg}
    end
    
    it "roundtrips DateTime" do
      datetime = DateTime.now
      MongoDoc::BSON.decode(datetime.to_bson).to_s.should == datetime.to_s
    end
  end
  
  describe "Mongo Classes" do
    [Mongo::ObjectID.new, Mongo::DBRef.new('ns', 1), Mongo::Code.new('code'), Mongo::Binary.new, Mongo::RegexpOfHolding.new('a', 'i', 'g')].each do |obj|
      it "#to_bson for #{obj.class.name} returns self" do
        obj.to_bson.should == obj
      end
      
      it "objects of type #{obj.class.name} decode to themselves" do
        hash = {"mongo" => obj}
        MongoDoc::BSON.decode(hash.to_bson)["mongo"].should == obj
      end
    end
  end
  
  describe "Extensions to Object" do
    before do
      @movie = Movie.new
      @movie.title = 'Gone with the Wind'
      @movie.director = 'Victor Fleming'
      @movie.writers = ['Sidney Howard']
      @director = Director.new
      @director.name = 'Victor Fleming'
      @director.awards = ['1940 - Best Director']
      @movie.director = @director
    end

    it "renders a json representation of a simple object" do
      @director.to_bson.should be_bson_eql({"name" => "Victor Fleming", MongoDoc::BSON::CLASS_KEY => "Director", "awards" => ["1940 - Best Director"]})
    end
    
    it "renders a json representation of an object with embedded objects" do
      @movie.to_bson.should be_bson_eql({"title" => "Gone with the Wind", MongoDoc::BSON::CLASS_KEY => "Movie", "writers" => ["Sidney Howard"], "director" => {"name" => "Victor Fleming", MongoDoc::BSON::CLASS_KEY => "Director", "awards" => ["1940 - Best Director"]}})
    end

    it "ignores a class hash when the :raw_json option is used" do
      Movie.bson_create(@movie.to_bson.except(MongoDoc::BSON::CLASS_KEY), :raw_json => true).director.should == @director.to_bson
    end

    it "roundtrips the object" do
      MongoDoc::BSON.decode(@movie.to_bson).should be_kind_of(Movie)
    end

    it "allows for embedded objects" do
      movie_from_bson = MongoDoc::BSON.decode(@movie.to_bson)
      movie_from_bson.director.should be_kind_of(Director)
    end

    it "allows for embedded arrays of objects" do
      award = AcademyAward.new
      award.year = '1940'
      award.category = 'Best Director'
      @director.awards = [award]
      director_from_bson = MongoDoc::BSON.decode(@director.to_bson)
      director_from_bson.awards.each {|award| award.should be_kind_of(AcademyAward)}
    end
  end
  
  describe "MongoDoc::Base" do
    before do
      @address = Address.new
      @address.street = '320 1st Street North'
      @address.city = 'Jacksonville Beach'
      @address.state = 'FL'
      @address.zip_code = '32250'
      @location = Location.new
      @location.address = @address
    end

    it "encodes the class for the object" do
      atom = Automobile::Ariel.new
      atom.to_bson[MongoDoc::BSON::CLASS_KEY].should == Automobile::Ariel.name
    end
    
    it "renders a json representation of the object" do
      @location.to_bson.should be_bson_eql({MongoDoc::BSON::CLASS_KEY => "Location", "website" => nil, "address" => {"state" => "FL", MongoDoc::BSON::CLASS_KEY => "Address", "zip_code" => "32250", "street" => "320 1st Street North", "city" => "Jacksonville Beach"}})
    end

    it "roundtrips the object" do
      MongoDoc::BSON.decode(@location.to_bson).should be_kind_of(Location)
    end

    it "ignores a class hash when the :raw_json option is used" do
      Location.bson_create(@location.to_bson.except(MongoDoc::BSON::CLASS_KEY), :raw_json => true).address.should == @address.to_bson
    end

    it "allows for embedded MongoDoc objects" do
      company_from_bson = MongoDoc::BSON.decode(@location.to_bson)
      company_from_bson.should be_kind_of(Location)
      company_from_bson.address.should be_kind_of(Address)
    end

    it "allows for derived classes" do
      wifi = WifiAccessible.new
      wifi.address = @address
      wifi.network_name = 'hashrocket'
      wifi_from_bson = MongoDoc::BSON.decode(wifi.to_bson)
      wifi_from_bson.should be_kind_of(WifiAccessible)
      wifi_from_bson.address.should be_kind_of(Address)
    end

    it "allows for embedded ruby objects" do
      website = WebSite.new
      website.url = 'http://hashrocket.com'
      wifi = WifiAccessible.new
      wifi.website = website
      wifi_from_bson = MongoDoc::BSON.decode(wifi.to_bson)
      wifi_from_bson.should be_kind_of(WifiAccessible)
      wifi_from_bson.website.should be_kind_of(WebSite)
    end
  end  
end
