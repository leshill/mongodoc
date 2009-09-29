class Object
  def to_json(*args)
    {'json_class' => self.class.name}.tap do |json_hash|
      instance_variables.each do |name|
        json_hash[name[1..-1]] = instance_variable_get(name).to_json
      end
    end
  end
  
  def self.object_create(json_hash, options = {})
    new.tap do |obj|
      json_hash.each do |name, value|
        obj.instance_variable_set("@#{name}", MongoDoc::JSON.decode(value))
      end
    end
  end
end
