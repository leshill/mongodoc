require 'rubygems'
gem 'mongo', '0.15'
require 'mongo'
require 'activesupport'

module MongoDoc
  VERSION = '0.1'
  
  class NoConnectionError < RuntimeError; end
  class NoDatabaseError < RuntimeError; end
end

require 'mongodoc/base'
