require 'rubygems'

gem 'mongo', '0.16'
gem 'jnunemaker-validatable', '1.8.0'

require 'mongo'
require 'activesupport'
require 'validatable'

module MongoDoc
  VERSION = '0.1'
  
  class NoConnectionError < RuntimeError; end
  class NoDatabaseError < RuntimeError; end
end

require 'mongodoc/base'
