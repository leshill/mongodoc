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
  
  it ".collection calls through MongoDoc.database using the class name" do
    db = stub('db')
    db.should_receive(:collection).with(MongoDoc::Base.to_s.tableize.gsub('/', '.'))
    MongoDoc.should_receive(:database).and_return(db)
    MongoDoc::Base.collection
  end
end
