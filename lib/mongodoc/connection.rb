module MongoDoc
  extend self

  attr_writer :config_path, :env, :host, :name, :options, :port, :strict

  def config_path
    @config_path || './mongodb.yml'
  end

  def configuration
    @configuration ||= File.exists?(config_path) ? YAML.load_file(config_path)[env] : {}
  end

  def connection
    @connection ||= connect
  end

  def database
    @database ||= connection.db(name, :strict => strict)
  end

  def env
    if rails?
      rails_env
    else
      @env ||= 'development'
    end
  end

  def host
    @host ||= configuration['host']
  end

  def name
    @name ||= configuration['name'] || default_name
  end

  def options
    @options ||= configuration['options'] || {}
  end

  def port
    @port ||= configuration['port']
  end

  def strict
    @strict ||= configuration['strict'] || false
  end

  private

  def connect
    connection = Mongo::Connection.new(host, port, options)
    raise NoConnectionError unless connection
    verify_server_version(connection)
    connection
  end

  def default_name
    if rails?
      rails_env
    else
      "mongodoc"
    end
  end

  def rails?
    Object.const_defined?("Rails")
  end

  def rails_env
    Rails.env
  end

  def verify_server_version(connection)
    raise UnsupportedServerVersionError.new('MongoDoc requires at least mongoDB version 1.3.2') unless connection.server_version >= "1.3.2"
  end

end
