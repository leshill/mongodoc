require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "JSON" do
  describe "#decode" do
    it "just returns the json if the :raw_json option is used" do
      hash = {}
      MongoDoc::JSON.should_not_receive(:object_create)
      MongoDoc::JSON.decode(hash, :raw_json => true).should == hash
    end

    it "calls object_create if parameter is a hash" do
      hash = {}
      options = {:option => true}
      MongoDoc::JSON.should_receive(:object_create).with(hash, options)
      MongoDoc::JSON.decode(hash, options)
    end

    it "if parameter is an array, it calls array_create" do
      array = []
      options = {:option => true}
      MongoDoc::JSON.should_receive(:array_create).with(array, options)
      MongoDoc::JSON.decode(array, options)
    end
    
    it "returns the json value as is if the parameter is not a hash or array" do
      ["", 1, 1.5, true, false, nil].each do |type_value|
        MongoDoc::JSON.decode(type_value).should == type_value
      end
    end
  end

  describe "#array_create" do
    it "calls decode for each element" do
      first = 1
      array = [first]
      options = {:option => true}
      MongoDoc::JSON.should_receive(:decode).with(first, options)
      MongoDoc::JSON.array_create(array, options)
    end
    
    it "just returns the array if the :raw_json option is used" do
      hash = {'key' => 'value', MongoDoc::JSON::CLASS_KEY => 'Date'}
      array = [hash]
      MongoDoc::JSON.should_not_receive(:decode)
      MongoDoc::JSON.array_create(array, :raw_json => true).should == array
    end
  end
  
  describe "#object_create" do
    it "leaves a simple hash intact" do
      hash = {}
      MongoDoc::JSON.object_create(hash).should == hash
    end
    
    it "a class hash extracts the class, and calls class.object_create" do
      base_hash = {'key' => 'value'}
      json_hash = base_hash.merge(MongoDoc::JSON::CLASS_KEY => 'Date')
      Date.should_receive(:object_create).with(base_hash)
      MongoDoc::JSON.object_create(json_hash)
    end
    
    it "ignores a class hash when the :raw_json option is used" do
      hash = {'key' => 'value', MongoDoc::JSON::CLASS_KEY => 'Date'}
      MongoDoc::JSON.object_create(hash, :raw_json => true).should == hash
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
      @director.to_json.should be_json_eql({"name" => "Victor Fleming","json_class" => "Director","awards" => ["1940 - Best Director"]})
    end
    
    it "renders a json representation of an object with embedded objects" do
      @movie.to_json.should be_json_eql({"title" => "Gone with the Wind","json_class" => "Movie","writers" => ["Sidney Howard"], "director" => {"name" => "Victor Fleming","json_class" => "Director","awards" => ["1940 - Best Director"]}})
    end

    it "roundtrips the object" do
      MongoDoc::JSON.decode(@movie.to_json).should be_kind_of(Movie)
    end

    it "allows for embedded objects" do
      movie_from_json = MongoDoc::JSON.decode(@movie.to_json)
      movie_from_json.director.should be_kind_of(Director)
    end

    it "allows for embedded arrays of objects" do
      award = AcademyAward.new
      award.year = '1940'
      award.category = 'Best Director'
      @director.awards = [award]
      director_from_json = MongoDoc::JSON.decode(@director.to_json)
      director_from_json.awards.each {|award| award.should be_kind_of(AcademyAward)}
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

    it "renders a json representation of the object" do
      @location.to_json.should be_json_eql({"json_class" => "Location", "website" => "null", "address" => {"state" => "FL","json_class" => "Address","zip_code" => "32250","street" => "320 1st Street North","city" => "Jacksonville Beach"}})
    end

    it "roundtrips the object" do
      MongoDoc::JSON.decode(@location.to_json).should be_kind_of(Location)
    end

    it "allows for embedded MongoDoc objects" do
      company_from_json = MongoDoc::JSON.decode(@location.to_json)
      company_from_json.should be_kind_of(Location)
      company_from_json.address.should be_kind_of(Address)
    end

    it "allows for derived classes" do
      wifi = WifiAccessible.new
      wifi.address = @address
      wifi.network_name = 'hashrocket'
      wifi_from_json = MongoDoc::JSON.decode(wifi.to_json)
      wifi_from_json.should be_kind_of(WifiAccessible)
      wifi_from_json.address.should be_kind_of(Address)
    end

    it "allows for embedded ruby objects" do
      website = WebSite.new
      website.url = 'http://hashrocket.com'
      wifi = WifiAccessible.new
      wifi.website = website
      wifi_from_json = MongoDoc::JSON.decode(wifi.to_json)
      wifi_from_json.should be_kind_of(WifiAccessible)
      wifi_from_json.website.should be_kind_of(WebSite)
    end
  end  
end
