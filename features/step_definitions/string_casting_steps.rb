def last
  @last
end

def last=(value)
  @last = value
end

def all
  @all ||= []
end

def all=(value)
  @all = value
end

Given /^a class Event$/ do
end

When /^I create an (.+) '(.+)' with:$/ do |klass_name, object_name, table|
  klass = klass_name.constantize
  table.hashes.each do |hash|
    self.last = klass.new
    hash.each do |attr, value|
      last.send("#{attr.underscore.gsub(' ', '_')}=", value)
    end
    all << last
  end
  instance_variable_set("@#{object_name}", last)
end

Then /^the object '(.+)' has an attribute '(.+)' of type (.*)$/ do |object_name, attr_name, type_name|
  object = instance_variable_get("@#{object_name}")
  type_name.constantize.should === object.send(attr_name)
end

