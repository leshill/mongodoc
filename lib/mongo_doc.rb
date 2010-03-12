require 'mongo'
require 'active_support'
require 'validatable'
require 'will_paginate/collection'

module MongoDoc
  VERSION = '0.3.2'
end

require 'mongo_doc/connection'
require 'mongo_doc/collection'
require 'mongo_doc/document'
