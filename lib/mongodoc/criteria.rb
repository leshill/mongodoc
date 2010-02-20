require 'mongoid/extensions/hash/criteria_helpers'
require 'mongoid/extensions/symbol/inflections'
require 'mongodoc/matchers'
require 'mongodoc/contexts'
require 'mongoid/criteria'

Hash.send(:include, Mongoid::Extensions::Hash::CriteriaHelpers)
Symbol.send(:include, Mongoid::Extensions::Symbol::Inflections)
