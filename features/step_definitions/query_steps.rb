def klass(klass_name = nil)
  @klass ||= klass_name.singularize.camelize.constantize
end

def query(klass_name = nil)
  @query ||= klass(klass_name).criteria
end

Then /^the (first|last) query result is equal to the document '(.*)'$/ do |position, name|
  object = instance_variable_get("@#{name}")
  query.send(position).should == object
end

Then /^one of the query results is the document '(.*)'$/ do |name|
  object = instance_variable_get("@#{name}")
  query.any? {|doc| doc == object}
end

Then /^the aggregate query result with "(.*)" == "(.*)" has a count of (.*)$/ do |key, value, count|
  result = query.aggregate
  result.find {|r| r.has_key?(key) and r[key] == value }['count'].should == count.to_i
end

Then /^the query result has (.*) documents*$/ do |count|
  if query.respond_to?(:size)
    query.size.should == count.to_i
  else
    query.count.should == count.to_i
  end
end

Then /^the size of the query result is (.*)$/ do |count|
  query.to_a.size.should == count.to_i
end

Then /^the group query result with "([^\"]*)" == "([^\"]*)" has the document '(.*)'$/ do |key, value, name|
  object = instance_variable_get("@#{name}")
  result = query.group
  result.find {|r| r.has_key?(key) and r[key] == value }['group'].should include(object)
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

