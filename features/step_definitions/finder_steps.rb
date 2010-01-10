def finder_query=(finder)
  @query = finder
end

When /^I query (.+) with (\w+)$/ do |doc, finder|
  self.finder_query = klass(doc).send(finder)
end

Then /^the query result was (\d+) documents$/ do |count|
  query.should == count.to_i
end
