$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'cucumber'
require 'spec/expectations'
require 'spec/bson_matchers'
require 'mongodoc'

MongoDoc.config_path = './features/mongodb.yml'
MongoDoc.connect_to_database

World(BsonMatchers)
