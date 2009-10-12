require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoDoc::Base" do
  describe ".key macro" do
    describe "accessors" do
      subject do
        Address.new
      end

      %w(street city state zip_code).each do |attr|
        it "has a #{attr} reader" do
          should respond_to(attr)
        end

        it "has a #{attr} writer" do
          should respond_to("#{attr}=")
        end
      end

      it "roundtrips the attribute" do
        address = Address.new
        street = '312 First Street North'
        address.street = street
        address.street.should == street
      end
    end
    
    describe "used with inheritance" do
      it "should have the keys from the parent class" do
        WifiAccessible.keys.should include(*Location.keys)
      end
    end
  end

  context "#save" do
    before do
      @address = Address.new
      @collection = stub('collection')
      Address.stub(:collection).and_return(@collection)
    end

    it "saves a #to_bson on the collection" do
      bson = stub('bson')
      @address.should_receive(:to_bson).and_return(bson)
      @collection.should_receive(:save).with(bson).and_return(Mongo::ObjectID.new([1]))
      @address.save
    end

    it "returns self with the _id of the document set" do
      id = Mongo::ObjectID.new([1])
      @collection.stub(:save).and_return(id)
      @address.save.should == @address
      @address._id.should == id
    end
  end

  it ".count calls the collection count" do
    collection = stub('collection')
    MongoDoc::Base.stub(:collection).and_return(collection)
    collection.should_receive(:count).and_return(1)
    MongoDoc::Base.count
  end

  it ".collection_name returns the name of the collection for this class" do
    Address.collection_name.should == Address.to_s.tableize.gsub('/', '.')
  end

  it ".collection calls through MongoDoc.database using the class name" do
    db = stub('db')
    db.should_receive(:collection).with(MongoDoc::Base.to_s.tableize.gsub('/', '.'))
    MongoDoc.should_receive(:database).and_return(db)
    MongoDoc::Base.collection
  end
end
