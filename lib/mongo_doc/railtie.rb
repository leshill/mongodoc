require 'mongo_doc'
require 'rails'
require 'mongo_doc/railties/config'

module MongoDoc
  class Railtie < Rails::Railtie
    initializer "mongo_doc db configuration" do |app|
      MongoDoc::Railties::Config.config(app)
    end

    rake_tasks do
      load File.dirname(__FILE__) + "/railties/db_prepare.task"
    end
  end
end
