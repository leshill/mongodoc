require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoDoc::Base" do
  describe ".key macro" do
    class TestKeys < MongoDoc::Base
    end
    
    it "adds its arguments to _keys" do
      TestKeys.key :attr1, :attr2
      TestKeys._keys.should == [:attr1, :attr2]
    end

    describe "accessors" do
      before do
        TestKeys.key :attr1
      end
      
      subject do
        TestKeys.new
      end
      
      it "has an attr1 reader" do
        should respond_to(:attr1)
      end

      it "has an attr1 writer" do
        should respond_to(:attr1=)
      end
    end
    
    describe "used with inheritance" do
      class TestParent < MongoDoc::Base
        key :parent_attr
      end
      
      class TestChild < TestParent
        key :child_attr
      end
      
      it "has its own keys" do
        TestChild._keys.should include(:child_attr)
      end
      
      it "has the keys from the parent class" do
        TestChild._keys.should include(*TestParent._keys)
      end
    end
  end

  context "satisfies form_for requirements" do
    before do
      @address = Address.new
      @address._id = '1'
    end
    
    it "#id returns the _id" do
      @address.id.should == @address._id
    end
    
    it "#to_param returns the _id" do
      @address.to_param.should == @address._id
    end
    
    context "#new_record?" do
      it "is true when the object does not have an _id" do
        @address._id = nil
        @address.new_record?.should be_true
      end
      
      it "is false when the object has an id" do
        @address.new_record?.should be_false
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

    it "returns the _id of the document" do
      id = Mongo::ObjectID.new([1])
      @collection.stub(:save).and_return(id)
      @address.save.should == id
    end
    
    it "sets the _id of the document" do
      id = Mongo::ObjectID.new([1])
      @collection.stub(:save).and_return(id)
      @address.save
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
