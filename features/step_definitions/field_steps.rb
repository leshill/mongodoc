Then /^the field (\w+) of the document '(\w+)' is not nil$/ do |field, name|
  doc = instance_variable_get("@#{name}")
  doc.send(field).should_not be_nil
end

When /^'(\w+)' references '(\w+)' as '(\w+)'$/ do |parent, child, field|
  parent_doc = instance_variable_get("@#{parent}")
  child_doc = instance_variable_get("@#{child}")
  parent_doc.send("#{field}=", child_doc)
end

When /^'(\w+)' references '(\w+)' through '(\w+)'$/ do |parent, child, field|
  parent_doc = instance_variable_get("@#{parent}")
  child_doc = instance_variable_get("@#{child}")
  parent_doc.send("#{field.singularize}_ids") << child_doc._id
end

Then /^'(\w+)' refers to '(\w+)' as '(\w+)'$/ do |name, other, field|
  doc = instance_variable_get("@#{name}")
  other_doc = instance_variable_get("@#{other}")
  doc.send("#{field}").should == other_doc
end

Then /^'(\w+)' has '(\w+)' that include '(\w+)'$/ do |name, field, included|
  doc = instance_variable_get("@#{name}")
  included_doc = instance_variable_get("@#{included}")
  doc.send("#{field}").should include(included_doc)
end
