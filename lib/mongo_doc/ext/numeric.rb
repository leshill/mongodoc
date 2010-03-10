class Numeric
  def to_bson(*args)
    self
  end
end

class BigDecimal
  def self.cast_from_string(string)
    BigDecimal.new(string) unless string.blank?
  end
end

class Integer
  def self.cast_from_string(string)
    string.to_i unless string.blank?
  end
end
