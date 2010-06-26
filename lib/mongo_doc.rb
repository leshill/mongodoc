require 'mongo'
require 'active_support'
require 'active_support/core_ext'

module MongoDoc
  VERSION = '0.6.1'
end

require 'mongo_doc/connection'
require 'mongo_doc/collection'
require 'mongo_doc/document'

require 'mongo_doc/railtie' if defined?(Rails)
