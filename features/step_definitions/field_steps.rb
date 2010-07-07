Then /^the field (\w+) of the document '(\w+)' is not nil$/ do |field, name|
  doc = instance_variable_get("@#{name}")
  doc.send(field).should_not be_nil
end
