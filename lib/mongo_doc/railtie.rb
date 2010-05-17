require 'mongo_doc'
require 'rails'
require 'mongo_doc/railties/config'

module MongoDoc
  class Railtie < Rails::Railtie
    initializer "mongo_doc db configuration" do |app|
      MongoDoc::Railties::Config.config(app)
    end
  end
end
