require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoDoc::Collection" do
  it ".mongo_collection creates a Mongo::Collection of the appropriate name" do
    name = 'collection_name'
    db = stub('db')
    db.should_receive(:collection).with(name)
    MongoDoc.should_receive(:database).and_return(db)
    MongoDoc::Collection.mongo_collection(name)
  end
  
  it ".new generates a Mongo::Collection by calling .mongo_collection" do
    name = 'collection_name'
    MongoDoc::Collection.should_receive(:mongo_collection).with(name)
    MongoDoc::Collection.new(name)
  end
  
  context "with the underlying Mongo::Collection" do
    before do
      @mongo_collection = stub('collection')
      MongoDoc::Collection.stub(:mongo_collection).and_return(@mongo_collection)
    end
    
    it "#_collection is the underlying Mongo::Collection" do
      MongoDoc::Collection.new('collection_name')._collection.should == @mongo_collection
    end
  
    %w([] clear count create_index db drop drop_index drop_indexes group hint index_information name options remove).each do |delegated_method|
      it "delegates #{delegated_method} to the Mongo::Collection" do
        @mongo_collection.should_receive(delegated_method)
        MongoDoc::Collection.new('collection_name').send(delegated_method)
      end
    end
    
    context "#insert" do
      it "delegates to the Mongo::Collection" do
        doc = { 'sample' => 'data' }
        options = {:safe => false}
        @mongo_collection.should_receive(:insert).with(doc, options)
        MongoDoc::Collection.new('collection_name').insert(doc, options)
      end
      
      it "converts the doc_or_docs to bson" do
        doc = { :sample => 'data' }
        doc.should_receive(:to_bson)
        options = {:safe => false}
        @mongo_collection.stub(:insert)
        MongoDoc::Collection.new('collection_name').insert(doc, options)
      end
    end
    
    context "#find" do
      before do
        @query = { 'sample' => 'data' }
        @options = {:limit => 1}
        @block = lambda {}
      end
      
      it "delegates to the Mongo::Collection" do
        @mongo_collection.should_receive(:find).with(@query, @options, &@block)
        MongoDoc::Collection.new('collection_name').find(@query, @options, &@block)
      end

      it "turns the cursor into an array" do
        cursor = stub('cursor')
        cursor.should_receive(:to_a)
        @mongo_collection.stub(:find).and_return(cursor)
        MongoDoc::Collection.new('collection_name').find(@query, @options, &@block)
      end
      
      it "converts the array back from bson" do
        results = [{'some' => 'results'}]
        cursor = stub('cursor', :to_a => results)
        @mongo_collection.stub(:find).and_return(cursor)
        MongoDoc::BSON.should_receive(:decode).with(results)
        MongoDoc::Collection.new('collection_name').find(@query, @options)
      end
    end
    
    context "#find_one" do
      it "delegates to the Mongo::Collection" do
        spec_or_object_id = { 'sample' => 'data' }
        options = {:limit => 1}
        @mongo_collection.should_receive(:find_one).with(spec_or_object_id, options)
        MongoDoc::Collection.new('collection_name').find_one(spec_or_object_id, options)
      end

      it "converts the result back from bson" do
        spec_or_object_id = { 'sample' => 'data' }
        options = {:limit => 1}
        results = {'some' => 'result'}
        @mongo_collection.stub(:find_one).and_return(results)
        MongoDoc::BSON.should_receive(:decode).with(results)
        MongoDoc::Collection.new('collection_name').find_one(spec_or_object_id, options)
      end
    end

    context "#save" do
      it "delegates to the Mongo::Collection" do
        doc = { 'sample' => 'data' }
        options = {:safe => false}
        @mongo_collection.should_receive(:save).with(doc, options)
        MongoDoc::Collection.new('collection_name').save(doc, options)
      end

      it "converts the doc to bson" do
        doc = { :sample => 'data' }
        options = {:safe => false}
        doc.should_receive(:to_bson)
        @mongo_collection.stub(:save)
        MongoDoc::Collection.new('collection_name').save(doc, options)
      end
    end

    context "#update" do
      before do
        @spec = { 'sample' => 'old' }
        @doc = { 'sample' => 'data' }
        @options = {:safe => false}
        @database = stub('database', :db_command => nil)
        MongoDoc.stub(:database).and_return(@database)
      end
      
      it "delegates to the Mongo::Collection" do
        @mongo_collection.should_receive(:update).with(@spec, @doc, @options)
        MongoDoc::Collection.new('collection_name').update(@spec, @doc, @options)
      end
      
      it "converts the doc to bson" do
        @doc.should_receive(:to_bson)
        @mongo_collection.stub(:update)
        MongoDoc::Collection.new('collection_name').update(@spec, @doc, @options)
      end
      
      it "gets the last error from the database" do
        @mongo_collection.stub(:update)
        @database.should_receive(:db_command).with({'getlasterror' => 1})
        MongoDoc::Collection.new('collection_name').update(@spec, @doc, @options)
      end
      
      it "returns the updateExisting value of get last error" do
        result = 'check'
        @mongo_collection.stub(:update)
        @database.stub(:db_command).and_return({'updatedExisting' => result})
        MongoDoc::Collection.new('collection_name').update(@spec, @doc, @options).should == result
      end
      
      it "returns false otherwise" do
        @mongo_collection.stub(:update)
        MongoDoc::Collection.new('collection_name').update(@spec, @doc, @options).should be_false
      end
    end
  end
end