When /^I create an index named (.*) on the (.*) collection$/ do |index_name, doc|
  klass = doc.constantize
  klass.index(index_name)
end

Then /^there is an index on (.*) on the (.*) collection$/ do |index_name, doc|
  klass = doc.constantize
  klass.collection.index_information.should include("#{index_name}_1")
end

