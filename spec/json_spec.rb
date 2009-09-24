require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "JSON support" do
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

    it "renders a json representation of the object" do
      @movie.to_json.should be_json_eql("{\"title\":\"Gone with the Wind\",\"json_class\":\"Movie\",\"writers\":[\"Sidney Howard\"], \"director\":{\"name\":\"Victor Fleming\",\"json_class\":\"Director\",\"awards\":[\"1940 - Best Director\"]}}")
    end

    it "roundtrips the object" do
      JSON.parse(@movie.to_json).should be_kind_of(Movie)
    end

    it "allows for embedded objects" do
      movie_from_json = JSON.parse(@movie.to_json)
      movie_from_json.director.should be_kind_of(Director)
    end

    it "allows for embedded arrays of objects" do
      award = AcademyAward.new
      award.year = '1940'
      award.category = 'Best Director'
      @director.awards = [award]
      director_from_json = JSON.parse(@director.to_json)
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
      @location.to_json.should be_json_eql("{\"json_class\":\"Location\", \"website\":null, \"address\":{\"state\":\"FL\",\"json_class\":\"Address\",\"zip_code\":\"32250\",\"street\":\"320 1st Street North\",\"city\":\"Jacksonville Beach\"}}")
    end

    it "roundtrips the object" do
      JSON.parse(@location.to_json).should be_kind_of(Location)
    end

    it "allows for embedded MongoDoc objects" do
      company_from_json = JSON.parse(@location.to_json)
      company_from_json.should be_kind_of(Location)
      company_from_json.address.should be_kind_of(Address)
    end

    it "allows for derived classes" do
      wifi = WifiAccessible.new
      wifi.address = @address
      wifi.network_name = 'hashrocket'
      wifi_from_json = JSON.parse(wifi.to_json)
      wifi_from_json.should be_kind_of(WifiAccessible)
      wifi_from_json.address.should be_kind_of(Address)
    end

    it "allows for embedded ruby objects" do
      website = WebSite.new
      website.url = 'http://hashrocket.com'
      wifi = WifiAccessible.new
      wifi.website = website
      wifi_from_json = JSON.parse(wifi.to_json)
      wifi_from_json.should be_kind_of(WifiAccessible)
      wifi_from_json.website.should be_kind_of(WebSite)

    end
  end  
end
