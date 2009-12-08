module MongoDoc
  def self.database(name = nil)
    if name
      @@database = connection.db(name)
    else
      raise NoDatabaseError unless defined? @@database and @@database
      @@database
    end
  end

  def self.connection
    raise NoConnectionError unless defined? @@connection and @@connection
    @@connection
  end

  def self.connect(*args)
    opts = args.extract_options!
    @@connection = Mongo::Connection.new(args[0], args[1], opts)
  end
end
