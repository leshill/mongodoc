$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mongo_doc'
require 'rspec'
require 'rspec/autorun'
require 'bson_matchers'
require 'hash_matchers'
require 'array_including_argument_matcher'
require 'document_ext'

RSpec.configure do |config|
  config.include(BsonMatchers)
  config.include(HashMatchers)
end
