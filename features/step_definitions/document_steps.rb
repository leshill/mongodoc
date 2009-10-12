Given /^an empty (\w+) document collection$/ do |doc|
  klass = doc.constantize
  Given "an empty #{klass.collection_name} collection"
end

Given /^an (\w+) document named '(.*)' :$/ do |doc, name, table|
  klass = doc.constantize
  table.hashes.each do |hash|
    @last = klass.new
    hash.each do |attr, value|
      @last.send("#{attr.underscore.gsub(' ', '_')}=", value)
    end
  end
  instance_variable_set("@#{name}", @last)
end

When /^I save the document '(.*)'$/ do |name|
  object = instance_variable_get("@#{name}")
  @last_save = object.save
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
  object.class.find_one(object._id).should == object
end

