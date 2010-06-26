require 'spec_helper'

describe "MongoDoc::Cursor" do
  let(:mongo_cursor) { stub('cursor') }

  let(:collection) { stub('collection') }

  let(:cursor) { MongoDoc::Cursor.new(collection, mongo_cursor) }

  it "is Enumerable" do
    Enumerable.should === cursor
  end

  it ".new wraps a Mongo::Cursor" do
    cursor._cursor.should == mongo_cursor
  end

  it "#collection returns the MongoDoc::Collection for this cursor" do
    cursor.collection.should == collection
    cursor._collection.should == collection
  end

  context "with the underlying cursor" do
    %w(admin close closed? count explain fields full_collection_name hint limit order query_options_hash query_opts selector skip snapshot sort timeout).each do |delegated_method|
      it "delegates #{delegated_method} to the Mongo::Cursor" do
        mongo_cursor.should_receive(delegated_method)
        cursor.send(delegated_method)
      end
    end
  end

  context "#each" do
    it "delegates to the cursor" do
      mongo_cursor.should_receive(:each)
      cursor.each
    end

    it "decodes the return from the delegate" do
      bson = stub('bson')
      cursor.stub(:_cursor).and_return([bson])
      MongoDoc::BSON.should_receive(:decode).with(bson)
      cursor.each {}
    end

    it "calls the block with the decoded return" do
      result = stub('bson')
      cursor.stub(:_cursor).and_return([result])
      MongoDoc::BSON.stub(:decode).and_return(result)
      cursor.each {|obj| @obj = obj}
      @obj.should == result
    end
  end

  context "#next_document" do
    it "delegates to the cursor" do
      mongo_cursor.should_receive(:next_document)
      cursor.next_document
    end

    it "decodes the return from the delegate" do
      bson = stub('bson')
      mongo_cursor.stub(:next_document).and_return(bson)
      MongoDoc::BSON.should_receive(:decode).with(bson)
      cursor.next_document
    end

    it "returns nil if the delegate returns nil" do
      mongo_cursor.stub(:next_document)
      cursor.next_document.should be_nil
    end
  end

  context "#to_a" do
    it "delegates to the cursor" do
      mongo_cursor.should_receive(:to_a)
      cursor.to_a
    end

    it "decodes the return from the delegate" do
      array = stub('array')
      mongo_cursor.stub(:to_a).and_return(array)
      MongoDoc::BSON.should_receive(:decode).with(array)
      cursor.to_a
    end

    it "returns [] if the delegate returns []" do
      mongo_cursor.stub(:to_a).and_return([])
      cursor.to_a.should == []
    end
  end
end
