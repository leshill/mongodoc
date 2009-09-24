class Object
  def to_json(*args)
    {'json_class' => self.class.name}.tap do |json_hash|
      instance_variables.each do |name|
        json_hash[name[1..-1]] = instance_variable_get(name)
      end
    end.to_json(*args)
  end
  
  def self.json_create(json_hash)
    klass = json_hash.delete('json_class')
    return json_hash unless klass
    klass.constantize.new.tap do |obj|
      json_hash.each do |name, value|
        obj.instance_variable_set("@#{name}", value)
      end
    end
  end
end
