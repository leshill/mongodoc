When /^I remove '(.+)'$/ do |doc_name|
  doc = instance_variable_get("@#{doc_name}")
  doc.remove
end

Then /^the document '(.+)' is not found$/ do |doc_name|
  doc = instance_variable_get("@#{doc_name}")
  doc.class.find_one(doc.id)
end

Then /^an exception is raised if I remove '(.+)'$/ do |doc_name|
  doc = instance_variable_get("@#{doc_name}")
  lambda { doc.remove }.should raise_error
end
