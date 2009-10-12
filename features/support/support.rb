$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'cucumber'
require 'spec/expectations'
require 'spec/bson_matchers'
require 'mongodoc'
require File.join(File.dirname(__FILE__), '..', '..', 'spec', 'test_classes')
require File.join(File.dirname(__FILE__), '..', '..', 'spec', 'test_documents')

World(BsonMatchers)