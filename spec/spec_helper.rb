$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mongo_doc'
require 'rspec'

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.include(BsonMatchers)
  config.include(HashMatchers)
  config.include(ActiveModelBehavior)
end
