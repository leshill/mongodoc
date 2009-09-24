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
    end

    it "defines a reader that calls read_attribute" do
      address = Address.new
      address.should_receive(:read_attribute)
      address.street
    end

    it "defines a writer that calls write_attribute" do
      address = Address.new
      address.should_receive(:write_attribute)
      address.street = '312 First Street North'
    end
    
    describe "used with inheritance" do
      it "should have the keys from the parent class" do
        WifiAccessible.keys.should include(*Location.keys)
      end
    end
  end
  
  it ".collection calls through MongoDoc.database using the class name" do
    db = stub('db')
    db.should_receive(:collection).with(MongoDoc::Base.to_s.tableize.gsub('/', '.'))
    MongoDoc.should_receive(:database).and_return(db)
    MongoDoc::Base.collection
  end
end
