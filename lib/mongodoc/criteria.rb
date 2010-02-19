require 'mongoid/extensions/hash/criteria_helpers'
require 'mongodoc/matchers'
require 'mongodoc/contexts'
require 'mongoid/criteria'

Hash.send(:include, Mongoid::Extensions::Hash::CriteriaHelpers)
