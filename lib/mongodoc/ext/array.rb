class Array
  def to_json(*args)
    map {|item| item.to_json}
  end
end