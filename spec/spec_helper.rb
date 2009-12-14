$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mongodoc'
require 'spec'
require 'spec/autorun'
require 'bson_matchers'
require 'hash_matchers'
require 'document_ext'

Spec::Runner.configure do |config|
  config.include(BsonMatchers)
  config.include(HashMatchers)
end
