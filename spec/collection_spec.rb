require 'spec_helper'

describe "MongoDoc::Collection" do

  let(:mongo_collection) { stub('collection') }

  it ".new delegates to .mongo_collection" do
    name = 'collection_name'
    MongoDoc::Collection.should_receive(:mongo_collection).with(name).and_return(mongo_collection)
    MongoDoc::Collection.new(name)
  end

  context "with the underlying Mongo::Collection" do

    let(:collection) do
      MongoDoc::Collection.stub(:mongo_collection).and_return(mongo_collection)
      MongoDoc::Collection.new('collection_name')
    end

    it "has Criteria mixed in" do
      MongoDoc::Criteria.should === collection
    end

    it "#collection references self for Mongo context" do
      collection.send(:collection).should == collection
    end

    %w([] clear count create_index db distinct drop drop_index drop_indexes group hint index_information map_reduce mapreduce name options pk_factory remove rename size).each do |delegated_method|
      it "delegates #{delegated_method} to the Mongo::Collection" do
        mongo_collection.should_receive(delegated_method)
        collection.send(delegated_method)
      end
    end

    context "#find" do
      let(:cursor) { MongoDoc::Cursor.new(collection, stub('cursor', :close => nil)) }

      before do
        collection.stub(:wrapped_cursor).and_return(cursor)
      end

      it "wraps the cursor" do
        query = {'sample' => 'data'}
        options = { :limit => 1}
        collection.should_receive(:wrapped_cursor).with(query, options).and_return(cursor)
        collection.find(query, options)
      end

      it "calls the block with a wrapped cursor" do
        collection.find {|c| @result = c}
        @result.should == cursor
      end
    end

    context "#find_and_modify" do
      let(:bson) { stub('bson') }
      let(:options) { {:query => {:name => 'name'},
                       :update => {:title => 'title'},
                       :sort => [],
                       :remove => false,
                       :new => true
      } }

      before do
        mongo_collection.stub(:find_and_modify).and_return(bson)
      end

      it "delegates to the Mongo::Collection" do
        mongo_collection.should_receive(:find_and_modify).with(options)
        collection.find_and_modify(options)
      end

      it "converts the result back from bson" do
        MongoDoc::BSON.should_receive(:decode).with(bson)
        collection.find_and_modify(options)
      end

      it "returns the converted result" do
        obj = stub('obj')
        MongoDoc::BSON.stub(:decode).and_return(obj)
        collection.find_and_modify(options).should == obj
      end

      it "returns nil if the delegate returns nil" do
        mongo_collection.stub(:find_and_modify).and_return(nil)
        collection.find_and_modify(options).should be_nil
      end
    end

    context "#find_one" do
      let(:bson) { stub('bson') }

      before do
        mongo_collection.stub(:find_one).and_return(bson)
      end

      it "delegates to the Mongo::Collection" do
        spec = { 'sample' => 'data' }
        options = {:limit => 1}
        mongo_collection.should_receive(:find_one).with(spec, options)
        collection.find_one(spec, options)
      end

      it "converts the result back from bson" do
        MongoDoc::BSON.should_receive(:decode).with(bson)
        collection.find_one({ 'sample' => 'data' })
      end

      it "returns the converted result" do
        obj = stub('obj')
        MongoDoc::BSON.stub(:decode).and_return(obj)
        collection.find_one({ 'sample' => 'data' }).should == obj
      end

      it "returns nil if the delegate returns nil" do
        mongo_collection.stub(:find_one)
        collection.find_one({ 'sample' => 'data' }).should be_nil
      end
    end

    context "#insert" do
      let(:doc) { {'sample' => 'data'} }
      let(:options) { {:safe => false} }

      it "delegates to the Mongo::Collection" do
        mongo_collection.should_receive(:insert).with(doc, options)
        collection.insert(doc, options)
      end

      it "converts the doc_or_docs to bson" do
        doc.should_receive(:to_bson)
        mongo_collection.stub(:insert)
        collection.insert(doc, options)
      end

      it "returns the delegates result" do
        result = 'result'
        mongo_collection.stub(:insert).and_return(result)
        collection.insert(doc).should == result
      end
    end

    context "#save" do
      let(:doc) { {'sample' => 'data'} }

      it "delegates to the Mongo::Collection" do
        options = {:safe => false}
        mongo_collection.should_receive(:save).with(doc, options)
        collection.save(doc, options)
      end

      it "converts the doc to bson" do
        doc.should_receive(:to_bson)
        mongo_collection.stub(:save)
        collection.save(doc)
      end

      it "returns the delegates result" do
        result = 'result'
        mongo_collection.stub(:save).and_return(result)
        collection.save(doc).should == result
      end
    end

    context "#update" do
      let(:spec) { {'sample' => 'old'} }

      let(:doc) { {'sample' => 'data'} }

      let(:options) { {:safe => false} }

      before do
        collection.stub(:last_error).and_return('updatedExisting' => true)
        mongo_collection.stub(:update)
      end

      it "delegates to the Mongo::Collection" do
        mongo_collection.should_receive(:update).with(spec, doc, options)
        collection.update(spec, doc, options)
      end

      it "converts the doc to bson" do
        doc.should_receive(:to_bson)
        collection.update(spec, doc, options)
      end

      it "gets the last error from the database" do
        collection.should_receive(:last_error)
        collection.update(spec, doc, options)
      end

      it "returns the updateExisting value of get last error" do
        result = 'check'
        collection.stub(:last_error).and_return({'updatedExisting' => result})
        collection.update(spec, doc, options).should == result
      end

      it "returns false otherwise" do
        collection.stub(:last_error)
        collection.update(spec, doc, options).should be_false
      end
    end
  end
end
