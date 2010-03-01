require 'rubygems'

gem 'mongo', '0.19'
gem 'mongo_ext', '0.19'
gem 'durran-validatable', '2.0.1'
gem 'leshill-will_paginate', '2.3.11'

require 'mongo'
require 'active_support'
require 'validatable'
require 'will_paginate/collection'

module MongoDoc
  VERSION = '0.2.4'
end

require 'mongodoc/connection'
require 'mongodoc/collection'
require 'mongodoc/document'
