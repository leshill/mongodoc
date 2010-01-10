When /^I query (.*) with 'all'$/ do |doc|
  query(doc).all
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

When /^I query (.*) with the '(.*)' id$/ do |doc, name|
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
