When /^I update the '(.+)' for '(.+)' to '(.+)'$/ do |attr, doc_name, value|
  doc = instance_variable_get("@#{doc_name}")
  doc.update_attributes(attr => value)
end

