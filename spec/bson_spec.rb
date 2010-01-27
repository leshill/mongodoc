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
    [Mongo::ObjectID.new, Mongo::DBRef.new('ns', 1), Mongo::Code.new('code'), Mongo::Binary.new].each do |obj|
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
    class Simple
      attr_accessor :value
    end

    class Complex
      attr_accessor :array_of_simple
    end

    before do
      @value1 = 'value1'
      @simple1 = Simple.new
      @simple1.value = @value1
      @value2 = 'value2'
      @simple2 = Simple.new
      @simple2.value = @value2
      @complex = Complex.new
      @complex.array_of_simple = [@simple1, @simple2]
    end

    it "renders a json representation of a simple object" do
      @simple1.to_bson.should be_bson_eql({MongoDoc::BSON::CLASS_KEY => Simple.name, "value" => @value1})
    end

    it "renders a json representation of an object with embedded objects" do
      @complex.to_bson.should be_bson_eql({MongoDoc::BSON::CLASS_KEY => Complex.name, "array_of_simple" => [@simple1.to_bson, @simple2.to_bson]})
    end

    it "ignores a class hash when the :raw_json option is used" do
      Complex.bson_create(@complex.to_bson.except(MongoDoc::BSON::CLASS_KEY), :raw_json => true).array_of_simple.first.should == @simple1.to_bson
    end

    it "roundtrips the object" do
      MongoDoc::BSON.decode(@complex.to_bson).should be_kind_of(Complex)
    end

    it "allows for embedded arrays of objects" do
      obj = MongoDoc::BSON.decode(@complex.to_bson)
      obj.array_of_simple.each {|o| o.should be_kind_of(Simple)}
    end
  end
end
