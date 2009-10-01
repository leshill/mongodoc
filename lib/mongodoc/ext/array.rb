class Array
  def to_bson(*args)
    map {|item| item.to_bson(args)}
  end
end