Given /a new collection named '(.*)'/ do |name|
  MongoDoc::Connection.database.drop_collection(name)
  @collection = MongoDoc::Collection.new(name)
end

Given /^an empty (\w+) collection$/ do |name|
  MongoDoc::Connection.database.drop_collection(name)
  MongoDoc::Connection.database.create_collection(name, :strict => true)
end

Then /the collection should have (\d+) documents?/ do |count|
  @collection.count.should == count.to_i
end

