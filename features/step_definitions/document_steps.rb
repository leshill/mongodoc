Given /^an empty (\w+) document collection$/ do |doc|
  klass = doc.constantize
  Given "an empty #{klass.collection_name} collection"
end

Given /^an? (\w+) document named '(.*)' :$/ do |doc, name, table|
  @all = []
  klass = doc.constantize
  table.hashes.each do |hash|
    @last = klass.new
    hash.each do |attr, value|
      @last.send("#{attr.underscore.gsub(' ', '_')}=", value)
    end
    @all << @last
  end
  instance_variable_set("@#{name}", @last)
end

Given /^'(.*)' has one (.*?) as (.*) :$/ do |doc_name, class_name, assoc_name, table|
  doc = instance_variable_get("@#{doc_name}")
  obj = class_name.constantize.new
  table.hashes.each do |hash|
    hash.each do |key, value|
      obj.send("#{key.underscore.gsub(' ', '_')}=", value)
    end
  end
  doc.send("#{assoc_name.underscore.gsub(' ', '_')}=", obj)
  @last = obj
end

Given /^'(.*)' has (?:a|an|many) (.*) :$/ do |doc_name, assoc_name, table|
  doc = instance_variable_get("@#{doc_name}")
  table.hashes.each do |hash|
    doc.send(assoc_name).build(hash.inject({}) do |attrs, (attr, value)|
      attrs["#{attr.underscore.gsub(' ', '_')}"] = value
      attrs
    end)
  end
  @all = doc.send(assoc_name)
  @last = @all.last
end

Given /^I set the id on the document '(.*)' to (.*)$/ do |doc_name, value|
  doc = instance_variable_get("@#{doc_name}")
  doc._id = Mongo::ObjectID.new([value.to_i])
end

Given /^'(.+)' has one (.+?) as (.+?) \(identified by '(.+)'\):$/ do |doc_name, class_name, assoc_name, var_name, table|
  doc = instance_variable_get("@#{doc_name}")
  obj = class_name.constantize.new
  table.hashes.each do |hash|
    hash.each do |key, value|
      obj.send("#{key.underscore.gsub(' ', '_')}=", value)
    end
  end
  instance_variable_set("@#{var_name}", obj)
  doc.send("#{assoc_name.underscore.gsub(' ', '_')}=", obj)
  @last = obj
end

When /^I save the document '(.*)'$/ do |name|
  object = instance_variable_get("@#{name}")
  @last_return = object.save
end

When /^I save the last document$/ do
  @last_return = @last.save
end

When /^I create an (.*) '(.*)' from the hash '(.*)'$/ do |doc, name, hash|
  klass = doc.constantize
  attrs = instance_variable_get("@#{hash}")
  instance_variable_set("@#{name}", klass.create(attrs))
end

When /^I update the document '(.*)' with the hash named '(.*)'$/ do |doc_name, hash_name|
  doc = instance_variable_get("@#{doc_name}")
  attrs = instance_variable_get("@#{hash_name}")
  @last_return = doc.update_attributes(attrs)
end

When /^I query (.*) with criteria (.*)$/ do |doc, criteria_text|
  klass = doc.singularize.camelize
  @query = @last_return = eval("#{klass}.criteria.#{criteria_text}")
end

When /^I query (.*) with the '(.*)' id$/ do |doc, name|
  klass = doc.singularize.camelize.constantize
  doc = instance_variable_get("@#{name}")
  @query = @last_return = klass.criteria.id(doc.id).entries
end

When /^I find a (.*) using the id of '(.*)'$/ do |type, doc_name|
  klass = type.camelize.constantize
  doc = instance_variable_get("@#{doc_name}")
  @last_return = klass.find(doc.id)
end

When /^'(.+)' is the first (.+?) of '(.+)'$/ do |var_name, single_assoc, doc_name|
  doc = instance_variable_get("@#{doc_name}")
  instance_variable_set("@#{var_name}", doc.send(single_assoc.pluralize).first)
end

Then /^'(.*)' is not a new record$/ do |name|
  instance_variable_get("@#{name}").new_record?.should be_false
end

Then /the (.*) collection should have (\d+) documents?/ do |doc, count|
  klass = doc.constantize
  klass.count.should == count.to_i
end

Then /^the document '(.*)' roundtrips$/ do |name|
  object = instance_variable_get("@#{name}")
  from_db = object.class.find_one(object._id)
  from_db.should == object
  instance_variable_set("@#{name}", from_db)
end

Then /^the document '(.+)' does not roundtrip$/ do |name|
  object = instance_variable_get("@#{name}")
  from_db = object.class.find_one(object._id)
  from_db.should_not == object
end

Then /^the last return value is (.+)$/ do |bool_val|
  @last_return.should send("be_#{bool_val}")
end

Then /^the first (.*) of '(.*)' is not a new record$/ do |assoc, name|
  object = instance_variable_get("@#{name}")
  plural = assoc.pluralize
  object.send(plural).first.should_not be_new_record
end

Then /^the (\w*) of '(.*)' is not a new record$/ do |assoc, name|
  object = instance_variable_get("@#{name}")
  object.send(assoc).should_not be_new_record
end

Then /^the (\w*) of '(.*)' roundtrips$/ do |assoc, name|
  object = instance_variable_get("@#{name}")
  from_db = object.class.find_one(object._id)
  object.send(assoc).id.should == from_db.send(assoc).id
end

Then /^the size of the last return value is (.*)$/ do |count|
  @last_return.size.should == count.to_i
end
