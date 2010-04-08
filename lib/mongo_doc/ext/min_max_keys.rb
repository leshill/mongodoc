module BSON
  class MaxKey
    def to_bson(*args)
      self
    end
  end

  class MinKey
    def to_bson(*args)
      self
    end
  end
end
