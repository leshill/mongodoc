module BSON
  class ObjectID
    def to_bson(*args)
      self
    end

    def self.cast_from_string(string)
      ObjectID.from_string(string) unless string.blank?
    end
  end
end
