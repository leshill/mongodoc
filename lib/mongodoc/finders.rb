require 'mongodoc/criteria'

module MongoDoc
  module Finders
    def self.extended(base)
      base.extend(Criteria) unless base === Criteria
    end

    %w(all count first last).each do |name|
      module_eval <<-RUBY
        # #{name.humanize} for this +Document+ class
        #
        # <tt>Person.#{name}</tt>
        def #{name}
          criteria.#{name}
        end
      RUBY
    end

    # Find a +Document+ based on id (+String+ or +Mongo::ObjectID+)
    #
    # <tt>Person.find('1')</tt>
    # <tt>Person.find(obj_id_1, obj_id_2)</tt>
    def find(*args)
      criteria.id(*args)
    end

    # Find a +Document+ based on id (+String+ or +Mongo::ObjectID+)
    # or conditions
    #
    # <tt>Person.find_one('1')</tt>
    # <tt>Person.find_one(:where => {:age.gt > 25})</tt>
    def find_one(conditions_or_id)
      if Hash === conditions_or_id
        Mongoid::Criteria.translate(self, conditions_or_id).one
      else
        Mongoid::Criteria.translate(self, conditions_or_id)
      end
    end

  end
end
