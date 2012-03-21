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

Given /^a class (.+)$/ do |type_name|
  type_name.constantize.should be_kind_of(Class)
end

Given /^I create an (.+) '(.+)' with:$/ do |klass_name, object_name, table|
  step "an #{klass_name} document named '#{object_name}' :", table
end

Then /^the object '(.+)' has an attribute '(.+)' of type (.*)$/ do |object_name, attr_name, type_name|
  object = instance_variable_get("@#{object_name}")
  type_name.constantize.should === object.send(attr_name)
end

