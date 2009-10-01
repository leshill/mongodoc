class FalseClass
  def to_json(*args)
    self
  end
end

class TrueClass
  def to_json(*args)
    self
  end
end