Given /a new collection named '(.*)'/ do |name|
  @db.drop_collection(name)
  @collection = MongoDoc::Collection.new(name)
end

Given /^an empty (\w+) collection$/ do |name|
  @db.drop_collection(name)
  @db.create_collection(name, :strict => true)
end

Then /the collection should have (\d+) documents?/ do |count|
  @collection.count.should == count.to_i
end

