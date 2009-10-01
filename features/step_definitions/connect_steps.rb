Given /a valid connection to the '(.*)' database/ do |db|
  MongoDoc.connect
  @db = MongoDoc.database(db)
end

Given /a new collection named '(.*)'/ do |name|
  @db.drop_collection(name)
  @collection = @db.collection(name)
end