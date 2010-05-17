module MongoDoc
  module Railties
    module Config
      extend self

      def config(app)
        MongoDoc::Connection.config_path = app.root + 'config/mongodb.yml'
        MongoDoc::Connection.default_name = "#{app.root.basename}_#{Rails.env}"
        MongoDoc::Connection.env = Rails.env
      end
    end
  end
end
