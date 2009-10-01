When /^I save the json '(\{.*\})'$/ do |json_text|
  json = JSON.parse(json_text)
  @collection.save(json.to_bson)
end
