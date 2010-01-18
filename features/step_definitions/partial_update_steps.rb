When /^I(\sstrict\s|\s)update the '(.+)' for '(.+)' to '(.+)'$/ do |strict, attr, doc_name, value|
  doc = instance_variable_get("@#{doc_name}")
  attrs = {attr => value}
  attrs.merge!(:__strict__ => true) unless strict.blank?
  @last_return = doc.update_attributes(attrs)
end

When /^someone else changes the (.+?) '(.+)' of '(.+)' to$/ do |assoc_klass, assoc_name, name, table|
  orig = instance_variable_get("@#{name}")
  doc = orig.class.find_one(orig._id)
  obj = assoc_klass.constantize.new
  table.hashes.each do |hash|
    hash.each do |key, value|
      obj.send("#{key.underscore.gsub(' ', '_')}=", value)
    end
  end
  doc.send("#{assoc_name.underscore.gsub(' ', '_')}=", obj)
  doc.save
end

When /^someone else changes the (.+) of '(.+)':$/ do |assoc_name, name, table|
  orig = instance_variable_get("@#{name}")
  doc = orig.class.find_one(orig._id)
  doc.send(assoc_name).clear
  table.hashes.each do |hash|
    doc.send(assoc_name) << hash.inject({}) do |attrs, (attr, value)|
      attrs["#{attr.underscore.gsub(' ', '_')}"] = value
      attrs
    end
  end
  doc.save
end
