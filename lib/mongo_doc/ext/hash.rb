class Hash
  def to_bson(*args)
    {}.tap do |hash|
      each {|key, value| hash[key.to_s] = value.to_bson}
    end
  end  
end