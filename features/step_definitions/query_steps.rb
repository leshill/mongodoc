def klass(klass_name = nil)
  @klass ||= klass_name.singularize.camelize.constantize
end

def query(klass_name = nil)
  @query ||= klass(klass_name).criteria
end

When "I also want a $number query with criteria $criteria" do |number, criteria|
  instance_variable_set("@#{number}", eval("query.#{criteria}"))
end

When /^I requery$/ do
  # do nothing
end

Then /^the query result is equal to the document '(.*)'$/ do |name|
  doc = instance_variable_get("@#{name}")
  query.should == doc
end

Then /^one of the query results is the document '(.*)'$/ do |name|
  doc = instance_variable_get("@#{name}")
  query.any? {|d| d == doc}.should be_true
end

Then /^the query result with "(.*)" == "(.*)" has a count of (.*)$/ do |key, value, count|
  query.find {|r| r.has_key?(key) and r[key] == value }['count'].should == count.to_i
end

Then /^the query result with "([^\"]*)" == "([^\"]*)" has the document '(.*)'$/ do |key, value, name|
  doc = instance_variable_get("@#{name}")
  query.find {|r| r.has_key?(key) and r[key] == value }['group'].should include(doc)
end

Then /^the query result has (.*) documents*$/ do |count|
  if query.respond_to?(:size)
    query.size.should == count.to_i
  else
    query.count.should == count.to_i
  end
end

Then /^the (first|last) query result is the document '(.*)'$/ do |position, name|
  doc = instance_variable_get("@#{name}")
  query.entries.send(position).should == doc
end

Then /^the size of the query result is (.*)$/ do |count|
  query.to_a.size.should == count.to_i
end

Then /^the query result is the document '(.*)'$/ do |name|
  object = instance_variable_get("@#{name}")
  if query.kind_of?(Array)
    query.size.should == 1
    query.first.should == object
  else
    query.should == object
  end
end

Then /^the query (is|is not) (empty|blank)$/ do |is, empty|
  query.send("#{empty}?").should == (is == 'is')
end

Then /^the (.+) query (is|is not) (empty|blank)$/ do |number, is, empty|
  instance_variable_get("@#{number}").send("#{empty}?").should == (is == 'is')
end
