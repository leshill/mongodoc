module ValueEquals
  def ==(other)
    return false unless instance_variables.size == other.instance_variables.size
    instance_variables.all? {|var| self.instance_variable_get(var) == other.instance_variable_get(var)}
  end
end

class Movie
  include ValueEquals
  
  attr_accessor :title, :director, :writers
end

class Director
  include ValueEquals
  
  attr_accessor :name, :awards
end

class AcademyAward
  include ValueEquals
  
  attr_accessor :year, :category
end
