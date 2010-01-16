def finder_query=(finder)
  @query = finder
end

When /^I query (.+) with (\w+)$/ do |doc, finder|
  self.finder_query = klass(doc).send(finder)
end

When /^I query (.+) to find_one with the id of the '(.+)' document$/ do |collection, doc_name|
  self.finder_query = klass(collection).find_one(instance_variable_get("@#{doc_name}").id)
end

Then /^the query result was (\d+) documents$/ do |count|
  query.should == count.to_i
end
