When /^I save the json '(\{.*\})'$/ do |json_text|
  bson = JSON.parse(json_text).to_bson
  @last_save = @collection.save(bson)
end

Then /^the json '(\{.*\})' roundtrips$/ do |json_text|
  bson = JSON.parse(json_text).to_bson
  MongoDoc::BSON.decode(@collection.find_one(@last_save)).should be_mongo_eql(bson, false)
end
