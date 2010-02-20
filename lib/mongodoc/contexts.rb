# encoding: utf-8
require "mongoid/contexts/paging"
require "mongodoc/contexts/enumerable"
require "mongodoc/contexts/mongo"

module Mongoid
  module Contexts
    # Determines the context to be used for this criteria. If the class is an
    # embedded document, then the context will be the array in the has_many
    # association it is in. If the class is a root, then the database itself
    # will be the context.
    #
    # Example:
    #
    # <tt>Contexts.context_for(criteria)</tt>
    def self.context_for(criteria)
      if criteria.klass.respond_to?(:collection)
        return MongoDoc::Contexts::Mongo.new(criteria)
      end
      return MongoDoc::Contexts::Enumerable.new(criteria)
    end

  end
end
