Given /^I put the '(\w+)' object on key '(\w+)' of the '(\w+)' hash of '(\w+)'$/ do |value_name, key, assoc, doc_name|
  value = instance_variable_get("@#{value_name}")
  doc = instance_variable_get("@#{doc_name}")
  doc.send(assoc)[key] = value
end

