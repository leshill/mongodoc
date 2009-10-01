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
  json = instance_variable_get("@#{name}").to_bson
  @collection.save(json)
end
