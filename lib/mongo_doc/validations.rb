module MongoDoc
  module Validations
    def self.included(klass)
      klass.class_eval do
        if MongoDoc.const_defined?('ActiveModel')
          include MongoDoc::ActiveModel::ActiveModelCompliance
        else
          require 'mongo_doc/validations/macros'

          include ::Validatable
          extend Macros
        end
      end
    end
  end
end
