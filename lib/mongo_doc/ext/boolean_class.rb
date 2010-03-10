class Boolean
  def self.cast_from_string(value)
    value == '1' || value.downcase == 'true'
  end
end

class FalseClass
  def to_bson(*args)
    self
  end
end

class TrueClass
  def to_bson(*args)
    self
  end
end
