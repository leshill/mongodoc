require 'rubygems'

gem 'mongo', '0.18.3'
gem 'mongo_ext', '0.18.3'
gem 'durran-validatable', '2.0.1'
gem 'leshill-will_paginate', '2.3.11'

require 'mongo'
require 'activesupport'
require 'validatable'
require 'will_paginate/collection'

module MongoDoc
  VERSION = '0.3.0'

  class NoConnectionError < RuntimeError; end
  class NoDatabaseError < RuntimeError; end
  class UnsupportedOperation < RuntimeError; end
  class UnsupportedServerVersionError < RuntimeError; end
end

require 'mongodoc/connection'
require 'mongodoc/collection'
require 'mongodoc/document'
