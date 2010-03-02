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