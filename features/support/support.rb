$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'cucumber'
require 'spec/expectations'
require 'spec/bson_matchers'
require 'mongo_doc'

MongoDoc::Connection.env = 'cucumber'
MongoDoc::Connection.config_path = './features/mongodb.yml'

World(BsonMatchers)
