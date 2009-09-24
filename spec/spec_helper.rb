$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mongodoc'
require 'spec'
require 'spec/autorun'
require 'json_matchers'
require 'test_classes'
require 'test_documents'

Spec::Runner.configure do |config|
  config.include(JsonMatchers)
end
