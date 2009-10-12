require 'mongodoc/value_equals'

class Movie
  include MongoDoc::ValueEquals
  
  attr_accessor :title, :director, :writers
end

class Director
  include MongoDoc::ValueEquals
  
  attr_accessor :name, :awards
end

class AcademyAward
  include MongoDoc::ValueEquals
  
  attr_accessor :year, :category
end
