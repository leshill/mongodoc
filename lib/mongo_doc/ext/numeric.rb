class Numeric
  def to_bson(*args)
    self
  end
end

class Float
  def self.cast_from_string(string)
    string.to_f unless string.blank?
  end
end

class Integer
  def self.cast_from_string(string)
    string.to_i unless string.blank?
  end
end
