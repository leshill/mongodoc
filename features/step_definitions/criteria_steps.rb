def query(klass_name = nil)
  return @query if @query or klass_name.nil?
  klass = klass_name.singularize.camelize.constantize
  @query = klass.criteria
end

When /^I query (.*) to select fields? "([^\"]*)"$/ do |doc, fields|
  fields = fields.split
  query(doc).only(*fields)
end

When /^I query (.*) where "([^\"]*)"$/ do |doc, where_text|
  where = eval(where_text)
  query(doc).where(where)
end

When /^I query (.*) that excludes "([^\"]*)"$/ do |doc, exclude_text|
  exclude = eval(exclude_text)
  query(doc).excludes(exclude)
end

When /^I set the query on (.*) to (limit|skip) (.*)$/ do |doc, op, count|
  query(doc).send(op, count.to_i)
end


When /^I query (.*) with (every|not in|in) "([^\"]*)"$/ do |doc, op, hash_text|
  hash = eval(hash_text)
  query(doc).send(op.gsub(' ', '_'), hash)
end

When /^I query (.*) with '(.*)' id$/ do |doc, name|
  object = instance_variable_get("@#{name}")
  query(doc).id(object.id)
end

When /^I set the query extras limit on (.*) to (.*)$/ do |doc, count|
  query(doc).limit(count.to_i)
end

When /^I order the (.*) query by "([^\"]*)"$/ do |doc, order_text|
  order = eval(order_text)
  query(doc).order_by(order)
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
  query.count.should == count.to_i
end

Then /^the size of the query result is (.*)$/ do |count|
  query.to_a.size.should == count.to_i
end

Then /^the group query result with "([^\"]*)" == "([^\"]*)" has the document '(.*)'$/ do |key, value, name|
  object = instance_variable_get("@#{name}")
  result = query.group
  result.find {|r| r.has_key?(key) and r[key] == value }['group'].should include(object)
end

