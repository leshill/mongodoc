# encoding: utf-8
require "mongoid/contexts/paging"
require "mongo_doc/contexts/ids"
require "mongoid/contexts/enumerable"
require "mongo_doc/contexts/mongo"

module Mongoid
  module Contexts

    class UnknownContext < RuntimeError; end

    # Determines the context to be used for this criteria. If the class is an
    # embedded document, then the context will be the array in the embed_many
    # association it is in. If the class is a root, then the database itself
    # will be the context.
    #
    # Example:
    #
    # <tt>Contexts.context_for(criteria)</tt>
    def self.context_for(criteria)
      if criteria.klass.respond_to?(:_append)
        return Mongoid::Contexts::Enumerable.new(criteria)
      elsif criteria.klass.respond_to?(:collection)
        return MongoDoc::Contexts::Mongo.new(criteria)
      else
        raise UnknownContext.new("Context not found for: #{criteria.klass}")
      end
    end

  end
end
