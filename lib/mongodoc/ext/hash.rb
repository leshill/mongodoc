class Hash
  def to_json(*args)
    {}.tap do |hash|
      each {|key, value| hash[key.to_s] = value.to_json}
    end
  end  
end