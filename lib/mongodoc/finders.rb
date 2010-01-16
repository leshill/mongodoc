module MongoDoc
  module Finders
    [:all, :count, :first, :last].each do |name|
      module_eval <<-RUBY
        def #{name}
          Criteria.new(self).#{name}
        end
      RUBY
    end

    def criteria
      Criteria.new(self)
    end

    def find(*args)
      query = args.extract_options!
      which = args.first
      Criteria.translate(self, query).send(which)
    end

    def find_one(conditions_or_id)
      if Hash === conditions_or_id
        Criteria.translate(self, conditions_or_id).one
      else
        Criteria.translate(self, conditions_or_id)
      end
    end
  end
end
