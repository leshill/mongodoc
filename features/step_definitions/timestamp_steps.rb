Given /^I wait (\d+) seconds$/ do |count|
  sleep(count.to_i)
end

Then /^the created_at timestamp is not equal to the updated_at timestamp for the document '(\w+)'$/ do |doc_name|
  doc = instance_variable_get("@#{doc_name}")
  doc.created_at.should_not == doc.updated_at
end
