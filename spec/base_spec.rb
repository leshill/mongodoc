require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoDoc::Base" do

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

  context "validations" do
    class SimpleValidationTest < MongoDoc::Base
      key :data
      validates_presence_of :data
    end

    it "are part of Base" do
      Validatable.should === MongoDoc::Base.new
    end

    it "valid? fails when a document is invalid" do
      doc = SimpleValidationTest.new
      doc.should_not be_valid
      doc.should have(1).error_on(:data)
    end
  end

  context "#save" do
    before do
      @id = Mongo::ObjectID.new([1])
      @address = Address.new
      @collection = stub('collection')
      Address.stub(:collection).and_return(@collection)
    end

    it "saves a #to_bson on the collection" do
      bson = stub('bson')
      @address.should_receive(:to_bson).and_return(bson)
      @collection.should_receive(:save).with(bson, anything).and_return(Mongo::ObjectID.new([1]))
      @address.save
    end

    it "sets the _id of the document" do
      @collection.stub(:save).and_return(@id)
      @address.save
      @address._id.should == @id
    end

    it "returns the _id of the document" do
      @collection.stub(:save).and_return(@id)
      @address.save.should == @id
    end

    it "ignores validates if asked to" do
      @address.stub(:valid?).and_return(false)
      @collection.stub(:save).and_return(@id)
      @address.save(false).should == @id
    end

    it "returns false if the object is not valid" do
      @address.stub(:valid?).and_return(false)
      @address.save.should be_false
    end
  end

  context ".create" do
    it "calls insert with the :safe => false option" do
      collection = stub('collection')
      Address.stub(:collection).and_return(collection)
      collection.should_receive(:insert).with(anything, hash_including(:safe => false))
      Address.create
    end

    it "is false if the object is not valid" do
      class CreateValidationTest < MongoDoc::Base
        key :data
        validates_presence_of :data
      end

      CreateValidationTest.create.should be_false
    end
  end

  context "#bang methods!" do
    before do
      @address = Address.new
      @collection = stub('collection')
      Address.stub(:collection).and_return(@collection)
    end

    it "create! calls insert with the :safe => true option" do
      @collection.should_receive(:insert).with(anything, hash_including(:safe => true))
      Address.create!
    end

    it "create! raises if not valid" do
      class CreateBangValidationTest < MongoDoc::Base
        key :data
        validates_presence_of :data
      end

      expect do
        CreateBangValidationTest.create!
      end.should raise_error MongoDoc::Document::DocumentInvalidError
    end

    it "save! call insert with the :safe => true option" do
      @collection.should_receive(:save).with(anything, hash_including(:safe => true))
      @address.save!
    end

    it "save! raises if not valid" do
      @address.stub(:valid?).and_return(false)
      expect do
        @address.save!
      end.should raise_error(MongoDoc::Document::DocumentInvalidError)
    end
  end

  context "#update_attributes" do
    before do
      @attrs = {:state => 'FL'}
      @spec = {'_id' => 1}
      @address = Address.new(@spec)
      @collection = stub('collection', :update => nil, :find_one => {'updatedExisting' => true})
      Address.stub(:collection).and_return(@collection)
    end

    it "returns true on success" do
      @address.update_attributes(@attrs).should be_true
    end

    it "sets the attributes" do
      @address.update_attributes(@attrs)
      @address.state.should == 'FL'
    end

    it "updates the document with only the specified attributes" do
      @collection.should_receive(:update).with(@spec, MongoDoc::Query.set_modifier(@attrs.to_bson), :safe => false)
      @address.update_attributes(@attrs)
    end

    it "returns false if the object is not valid" do
      @address.stub(:valid?).and_return(false)
      @address.update_attributes(@attrs).should be_false
    end

    context "with a bang" do

      it "with a bang, updates the document with the :safe => true option" do
        @collection.should_receive(:update).with(@spec, MongoDoc::Query.set_modifier(@attrs.to_bson), :safe => true)
        @address.update_attributes!(@attrs)
      end

      it "raises if not valid" do
        @address.stub(:valid?).and_return(false)
        expect do
          @address.update_attributes!(@attrs)
        end.should raise_error(MongoDoc::Document::DocumentInvalidError)
      end
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
