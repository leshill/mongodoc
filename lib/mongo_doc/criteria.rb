require 'mongoid/extensions/hash/criteria_helpers'
require 'mongoid/extensions/symbol/inflections'
require 'mongo_doc/matchers'
require 'mongo_doc/contexts'
require 'mongoid/criteria'

module MongoDoc
  module Criteria
    # Create a criteria for this +Document+ class
    #
    # <tt>Person.criteria</tt>
    def criteria
      CriteriaWrapper.new(self)
    end

    delegate \
      :aggregate,
      :all,
      :and,
      :any_in,
      :blank?,
      :count,
      :empty?,
      :excludes,
      :extras,
      :first,
      :group,
      :id,
      :in,
      :last,
      :limit,
      :max,
      :min,
      :not_in,
      :offset,
      :one,
      :only,
      :order_by,
      :page,
      :paginate,
      :per_page,
      :skip,
      :sum,
      :where, :to => :criteria

    class CriteriaWrapper < Mongoid::Criteria
      %w(all and any_in cache enslave excludes extras fuse id in limit not_in offset only order_by skip where).each do |method|
        class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
          def #{method}_with_wrapping(*args, &block)                # def and(*args, &block)
            new_criteria = CriteriaWrapper.new(klass)               #   new_criteria = CriteriaWrapper.new(klass)
            new_criteria.merge(self)                                #   new_criteria.merge(criteria)
            new_criteria.#{method}_without_wrapping(*args, &block)  #   new_criteria.and_without_wrapping(*args, &block)
          end                                                       # end

          alias_method_chain :#{method}, :wrapping
          protected :#{method}_without_wrapping
        RUBY
      end

      protected

      attr_accessor :criteria

    end
  end
end

Hash.send(:include, Mongoid::Extensions::Hash::CriteriaHelpers)
Symbol.send(:include, Mongoid::Extensions::Symbol::Inflections)
