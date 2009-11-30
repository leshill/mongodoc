When /^I save the json '(\{.*\})'$/ do |json_text|
  json = JSON.parse(json_text)
  @last_save = @collection.save(json)
end

Then /^the json '(\{.*\})' roundtrips$/ do |json_text|
  json = JSON.parse(json_text)
  @collection.find_one(@last_save).should be_mongo_eql(json, false)
end
