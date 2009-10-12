module MongoDoc
  module ValueEquals
    def ==(other)
      return false unless instance_variables.size == other.instance_variables.size
      instance_variables.all? {|var| self.instance_variable_get(var) == other.instance_variable_get(var)}
    end
  end
end