def finder_query=(finder)
  @query = finder
end

When /^I query (.+) with (\w+)$/ do |doc, finder|
  self.finder_query = klass(doc).send(finder)
end

When /^I query (.+) to find_one with the (.+) of the '(.+)' document$/ do |collection, id, doc_name|
  self.finder_query = klass(collection).find_one(instance_variable_get("@#{doc_name}").send(id))
end

Then /^the query result (?:is|was) (\d+) documents$/ do |count|
  query.should == count.to_i
end
