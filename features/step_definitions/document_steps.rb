Given /^an empty (\w+) document collection$/ do |doc|
  klass = doc.constantize
  Given "an empty #{klass.collection_name} collection"
end

Given /^an (\w+) document named '(.*)' :$/ do |doc, name, table|
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

When /^I save the document '(.*)'$/ do |name|
  object = instance_variable_get("@#{name}")
  @last_save = object.save
end

When /^I create an (.*) '(.*)' from the hash '(.*)'$/ do |doc, name, hash|
  klass = doc.constantize
  attrs = instance_variable_get("@#{hash}")
  instance_variable_set("@#{name}", klass.create(attrs))
end

When /^I update the document '(.*)' with the hash named '(.*)'$/ do |doc_name, hash_name|
  doc = instance_variable_get("@#{doc_name}")
  attrs = instance_variable_get("@#{hash_name}")
  doc.update_attributes(attrs)
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

