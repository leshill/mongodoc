module MongoDoc
  mattr_accessor :config, :config_path, :connection, :database
  self.config_path = './mongodb.yml'

  def self.connect_to_database(name = nil, host = nil, port = nil, options = nil, force_connect = false)
    name ||= configuration['name']
    self.database = ((!force_connect && connection)|| connect(host, port, options)).db(name)
    raise NoDatabaseError unless database
    database
  end

  def self.connect(*args)
    opts = args.extract_options!
    host = args[0] || configuration['host'] || configuration['host_pairs']
    port = args[1] || configuration['port']
    options = opts.empty? ? configuration['options'] || {} : opts
    self.connection = Mongo::Connection.new(host, port, options)
    raise NoConnectionError unless connection
    verify_server_version
    connection
  end

  def self.configuration
    self.config ||= File.exists?(config_path || '') ? YAML.load_file(config_path) : {}
  end

  def self.verify_server_version
    raise UnsupportedServerVersionError.new('MongoDoc requires at least mongoDB version 1.3.2') unless connection.server_version >= "1.3.2"
  end
end
