Given /^an object '(.*)'$/ do |name|
  @movie = Movie.new
  @movie.title = 'Gone with the Wind'
  @movie.director = 'Victor Fleming'
  @movie.writers = ['Sidney Howard']
  @director = Director.new
  @director.name = 'Victor Fleming'
  @award = AcademyAward.new
  @award.year = '1940'
  @award.category = 'Best Director'
  @director.awards = [@award]
  @movie.director = @director
end

Given /^a hash named '(.*)':$/ do |name, table|
  @all = []
  table.hashes.each do |hash|
    @last = hash.inject({}) do |h, (key, value)|
      h["#{key.underscore.gsub(' ', '_')}"] = value
      h
    end
    @all << @last
  end
  instance_variable_set("@#{name}", @last)
end

Given /^'(.*)' has (.*), an array of:$/ do |name, attribute, table|
  object = instance_variable_get("@#{name}")
  object.send(attribute + "=", [])
  table.hashes.each do |hash|
    hash.each {|key, value| object.send(attribute) << value}
  end
end


When /^I save the object '(.*)'$/ do |name|
  object = instance_variable_get("@#{name}")
  @last_save = @collection.save(object)
end

Then /^the object '(.*)' roundtrips$/ do |name|
  object = instance_variable_get("@#{name}")
  object.instance_variable_set("@_id", @last_save)
  @collection.find_one(@last_save).should == object
end

Then /^the attribute '(.*)' of '(.*)' is '(.*)'$/ do |attr, var, value|
  object = instance_variable_get("@#{var}")
  object.send(attr).to_s.should == value
end
