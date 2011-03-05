require 'mongo_doc/criteria'

module MongoDoc
  module Finders
    def self.extended(base)
      base.extend(Criteria) unless base === Criteria
    end

    # Find a +Document+ based on id (+String+ or +BSON::ObjectID+)
    #
    # <tt>Person.find('1')</tt>
    # <tt>Person.find(obj_id_1, obj_id_2)</tt>
    def find(*args)
      criteria.id(*args)
    end
    #
    # Find all +Document+s in the collections
    #
    # <tt>Person.find_all</tt>
    def find_all
      criteria
    end

    # Find a +Document+ based on id (+String+ or +BSON::ObjectID+)
    # or conditions
    #
    # <tt>Person.find_one('1')</tt>
    # <tt>Person.find_one(:conditions => {:age.gt => 25}, :order_by => [[:name,
    # :asc]])</tt>
    def find_one(conditions_or_id)
      return nil if conditions_or_id.nil?
      if Hash === conditions_or_id
        Mongoid::Criteria.translate(self, conditions_or_id).one
      else
        Mongoid::Criteria.translate(self, conditions_or_id)
      end
    end

  end
end
