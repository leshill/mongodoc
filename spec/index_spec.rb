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
    attr_accessor :location, :type => Array

    embed :addresses

    # This is the API we are testing, commented out to avoid firing before
    # specs are run
    #
    # index :birthdate
    # index :ssn, :unique => true
    # index :first_name => :asc, :last_name => :asc
    # index :last_name => :asc, :first_name => :asc, :unique => true
    # index "addresses.state"
    # index :location => :geo2d
  end

  let(:collection) { stub('collection') }

  before do
    IndexTest.stub(:collection).and_return(collection)
  end

  context "Simple index" do

    it "creates an index for the field" do
      collection.should_receive(:create_index).with(:birthdate, {})
      IndexTest.index(:birthdate)
    end

    it "creates a unique index for the field" do
      collection.should_receive(:create_index).with(:birthdate, {:unique => true})
      IndexTest.index(:birthdate, :unique => true)
    end

  end

  context "Compound index" do

    it "creates a compound index" do
      collection.should_receive(:create_index).with(array_including([:first_name, Mongo::ASCENDING], [:last_name, Mongo::ASCENDING]), {})
      IndexTest.index(:first_name => :asc, :last_name => :asc)
    end

    it "creates a unique compound index" do
      collection.should_receive(:create_index).with(array_including([:first_name, Mongo::ASCENDING], [:last_name, Mongo::ASCENDING]), {:unique => true})
      IndexTest.index(:first_name => :asc, :last_name => :asc, :unique => true)
    end
  end

  context "Nested index" do
    it "creates an index for the field" do
      collection.should_receive(:create_index).with("addresses.state", {})
      IndexTest.index("addresses.state")
    end
  end

  context "Geo index" do
    it "creates a geo index for the field" do
      collection.should_receive(:create_index).with([[:location, Mongo::GEO2D]], {})
      IndexTest.index(:location => :geo2d)
    end
  end
end
