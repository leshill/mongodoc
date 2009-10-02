module SaneEqual
  def ==(other)
    return false unless instance_variables == other.instance_variables
    instance_variables.all? {|var| self.instance_variable_get(var) == other.instance_variable_get(var)}
  end
end

class Movie
  include SaneEqual
  
  attr_accessor :title, :director, :writers
end

class Director
  include SaneEqual
  
  attr_accessor :name, :awards
end

class AcademyAward
  include SaneEqual
  
  attr_accessor :year, :category
end
