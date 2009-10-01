$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'cucumber'
require 'spec/expectations'
require 'mongodoc'
require File.join(File.dirname(__FILE__), '..', '..', 'spec', 'test_classes')
