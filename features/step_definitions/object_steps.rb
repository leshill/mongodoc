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

When /^I save the object '(.*)'$/ do |name|
  object = instance_variable_get("@#{name}")
  @last_save = @collection.save(object.to_bson)
end

Then /^the object '(.*)' roundtrips$/ do |name|
  object = instance_variable_get("@#{name}")
  object.instance_variable_set("@_id", @last_save)
  MongoDoc::BSON.decode(@collection.find_one(@last_save)).should == object
end
