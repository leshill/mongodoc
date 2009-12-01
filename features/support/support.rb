$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'cucumber'
require 'spec/expectations'
require 'spec/bson_matchers'
require 'mongodoc'

World(BsonMatchers)