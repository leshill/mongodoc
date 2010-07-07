require 'spec_helper'

describe MongoDoc::Timestamps do
  class TimestampsTest
    include MongoDoc::Document

    attr_accessor :name

    timestamps!
  end

  let(:collection) { stub(:save => ::BSON::ObjectID.new, :update => true) }
  let(:document) { TimestampsTest.new }

  before do
    TimestampsTest.stub(:collection).and_return(collection)
  end

  it "has a created_at attribute" do
    document.should respond_to(:created_at)
    document.should respond_to(:created_at=)
  end

  it "has an updated_at attribute" do
    document.should respond_to(:updated_at)
    document.should respond_to(:updated_at=)
  end

  context "on initial save" do
    context "that suceeeds" do
      it "sets the created_at timestamp" do
        document.save
        document.created_at.should_not be_nil
      end

      it "sets the updated_at timestamp" do
        document.save
        document.updated_at.should_not be_nil
      end

      it "the created_at and updated_at timestamps are the same" do
        document.save
        document.created_at.should == document.updated_at
      end

      it "sets the timezone to UTC" do
        document.save
        document.created_at.zone.should == "UTC"
      end
    end

    context "that fails" do
      before do
        collection.stub(:save).and_raise(Mongo::MongoDBError.new)
      end

      it "does not set the created_at timestamp" do
        document.save rescue nil
        document.created_at.should be_nil
      end

      it "does not set the updated_at timestamp" do
        document.save rescue nil
        document.updated_at.should be_nil
      end
    end
  end

  context "on subsequent save" do
    before do
      document.save
    end

    context "that suceeeds" do
      let!(:original_created_at) { document.created_at }

      it "leaves the created_at timestamp unchanged" do
        document.save
        document.created_at.should == original_created_at
      end

      it "sets the updated_at timestamp" do
        document.save
        document.updated_at.should_not == original_created_at
      end

      it "the created_at and updated_at timestamps are not the same" do
        document.save
        document.created_at.should_not == document.updated_at
      end
    end

    context "that fails" do
      let!(:original_created_at) { document.created_at }

      before do
        collection.stub(:save).and_raise(Mongo::MongoDBError.new)
      end

      it "leaves the created_at timestamp unchanged" do
        document.save rescue nil
        document.created_at.should == original_created_at
      end

      it "leaves the updated_at timestamp unchanged" do
        document.save rescue nil
        document.updated_at.should == original_created_at
      end
    end
  end

  context "on update attributes" do
    before do
      document.save
    end

    context "that suceeeds" do
      let!(:original_created_at) { document.created_at }

      it "leaves the created_at timestamp unchanged" do
        document.update_attributes(:name => 'name')
        document.created_at.should == original_created_at
      end

      it "sets the updated_at timestamp" do
        document.update_attributes(:name => 'name')
        document.updated_at.should_not == original_created_at
      end

      it "the created_at and updated_at timestamps are not the same" do
        document.update_attributes(:name => 'name')
        document.created_at.should_not == document.updated_at
      end
    end

    context "that fails" do
      let!(:original_created_at) { document.created_at }

      before do
        collection.stub(:update).and_raise(Mongo::MongoDBError.new)
      end

      it "leaves the created_at timestamp unchanged" do
        document.update_attributes(:name => 'name') rescue nil
        document.created_at.should == original_created_at
      end

      it "leaves the updated_at timestamp unchanged" do
        document.update_attributes(:name => 'name') rescue nil
        document.updated_at.should == original_created_at
      end
    end
  end
end
