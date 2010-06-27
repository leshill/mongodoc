require 'spec_helper'
require 'mongo_doc/database_cleaner'

describe "MongoDoc::DatabaseCleaner" do

  describe "#clean_database" do

    let(:collections) { [people_collection, system_collection, remove_system_collection] }
    let(:database) { stub(:collections => collections) }
    let(:people_collection) { stub(:name => 'people_collection') }
    let(:system_collection) { stub(:name => 'system_collection') }
    let(:remove_system_collection) { stub(:name => 'remove_this_non_system_collection') }

    before do
      MongoDoc::Connection.stub(:database).and_return(database)
    end

    it "removes all the non-system collections" do
      MongoDoc::Connection.database.should_receive(:drop_collection).with(people_collection.name)
      MongoDoc::Connection.database.should_receive(:drop_collection).with(remove_system_collection.name)
      MongoDoc::DatabaseCleaner.clean_database
    end
  end
end
