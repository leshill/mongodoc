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

When "I query the collection '$collection_name' with the criteria $criteria" do |collection_name, criteria|
  @query = eval("@collection.#{criteria}")
end
