class Time
  def to_bson(*args)
    self
  end

  def self.cast_from_string(string)
    Time.parse(string) unless string.blank?
  end
end
