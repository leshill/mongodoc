Given /a valid connection to the '(.*)' database/ do |db|
  MongoDoc.connect
  @db = MongoDoc.database(db)
end
