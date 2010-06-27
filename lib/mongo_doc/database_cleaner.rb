module MongoDoc
  module DatabaseCleaner
    extend self

    def clean_database
      MongoDoc::Connection.database.collections.select {|c| c.name !~ /^system/}.each {|c| MongoDoc::Connection.database.drop_collection(c.name)}
    end
  end
end
