$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..'))
require 'cucumber'
require 'rspec/expectations'
require 'spec/bson_matchers'
require 'mongo_doc'
require 'active_support/json'

MongoDoc::Connection.env = 'cucumber'
MongoDoc::Connection.config_path = './features/mongodb.yml'

World(BsonMatchers)
