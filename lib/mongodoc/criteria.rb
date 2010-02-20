require 'mongoid/extensions/hash/criteria_helpers'
require 'mongoid/extensions/symbol/inflections'
require 'mongodoc/matchers'
require 'mongodoc/contexts'
require 'mongoid/criteria'

module MongoDoc
  module Criteria
    # Create a criteria for this +Document+ class
    #
    # <tt>Person.criteria</tt>
    def criteria
      Mongoid::Criteria.new(self)
    end

    delegate \
      :and,
      :cache,
      :enslave,
      :excludes,
      :extras,
      :id,
      :in,
      :limit,
      :not_in,
      :offset,
      :only,
      :order_by,
      :page,
      :per_page,
      :skip,
      :where, :to => :criteria
  end
end

Hash.send(:include, Mongoid::Extensions::Hash::CriteriaHelpers)
Symbol.send(:include, Mongoid::Extensions::Symbol::Inflections)
