require "spec_helper.rb"

describe MongoDoc::Index do
  class Address
    include MongoDoc::Document

    attr_accessor :state
  end

  class IndexTest
    include MongoDoc::Document

    attr_accessor :ssn
    attr_accessor :first_name
    attr_accessor :last_name
    attr_accessor :birthdate, :type => Date
    attr_accessor :notes

    embed :addresses

    # This is the API we are testing, commented out to avoid firing before
    # specs are run
    #
    # index :birthdate
    # index :ssn, :unique => true
    # index :first_name => :asc, :last_name => :asc
    # index :last_name => :asc, :first_name => :asc, :unique => true
    # index "addresses.state"
  end

  let(:collection) { stub('collection') }

  before do
    IndexTest.stub(:collection).and_return(collection)
  end

  context "Simple index" do

    it "creates an index for the field" do
      collection.should_receive(:create_index).with(:birthdate, false)
      IndexTest.index(:birthdate)
    end

    it "creates a unique index for the field" do
      collection.should_receive(:create_index).with(:birthdate, true)
      IndexTest.index(:birthdate, :unique => true)
    end

  end

  context "Compound index" do

    it "creates a compound index" do
      collection.should_receive(:create_index).with([[:first_name, Mongo::ASCENDING], [:last_name, Mongo::ASCENDING]], false)
      IndexTest.index(:first_name => :asc, :last_name => :asc)
    end

    it "creates a unique compound index" do
      collection.should_receive(:create_index).with([[:first_name, Mongo::ASCENDING], [:last_name, Mongo::ASCENDING]], true)
      IndexTest.index(:first_name => :asc, :last_name => :asc, :unique => true)
    end
  end

  context "Nested index" do
    it "creates an index for the field" do
      collection.should_receive(:create_index).with("addresses.state", false)
      IndexTest.index("addresses.state")
    end
  end
end
