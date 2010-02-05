$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'cucumber'
require 'spec/expectations'
require 'spec/bson_matchers'
require 'mongodoc'

MongoDoc::Connection.env = 'cucumber'
MongoDoc::Connection.config_path = './features/mongodb.yml'

World(BsonMatchers)
