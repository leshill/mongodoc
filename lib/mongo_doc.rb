require 'mongo'
require 'active_support'
require 'active_support/core_ext'
require 'mongo_doc/configuration'
require 'mongo_doc/connection'
require 'mongo_doc/collection'
require 'mongo_doc/document'

require 'mongo_doc/railtie' if defined?(Rails)
