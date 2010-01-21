require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoDoc Connections" do

  it "default the configuration location to './mongodb.yml'" do
    MongoDoc.config_path.should == './mongodb.yml'
  end

  describe ".verify_server_version" do
    let (:connection) { stub('connection') }

    before do
      MongoDoc.stub(:connection).and_return(connection)
    end

    it "raises when the server version is unsupported" do
      connection.stub(:server_version).and_return(Mongo::ServerVersion.new('1.3.0'))
      lambda { MongoDoc.verify_server_version }.should raise_error(MongoDoc::UnsupportedServerVersionError)
    end

    it "returns when the server version is supported" do
      connection.stub(:server_version).and_return(Mongo::ServerVersion.new('1.3.1'))
      lambda { MongoDoc.verify_server_version }.should_not raise_error(MongoDoc::UnsupportedServerVersionError)
    end
  end

  describe ".connect" do
    let (:connection) { stub('connection') }

    before do
      MongoDoc.config_path = nil
      MongoDoc.connection = nil
      MongoDoc.config = nil
      MongoDoc.stub(:verify_server_version)
    end

    it "when called with no params just connects" do
      Mongo::Connection.should_receive(:new).and_return(connection)
      MongoDoc.connect
    end

    it "sets the connection" do
      Mongo::Connection.stub(:new).and_return(connection)
      MongoDoc.connect
      MongoDoc.connection.should == connection
    end

    it "raises NoConnectionError if the connection fails" do
      Mongo::Connection.stub(:new).and_return(nil)
      lambda { MongoDoc.connect }.should raise_error(MongoDoc::NoConnectionError)
    end

    it "raises UnsupportedServerVersionError if the server version is unsupported" do
      Mongo::Connection.stub(:new).and_return(connection)
      MongoDoc.stub(:verify_server_version).and_raise(MongoDoc::UnsupportedServerVersionError)
      lambda { MongoDoc.connect }.should raise_error(MongoDoc::UnsupportedServerVersionError)
    end

    context "mimics the Mongo::Connection API" do
      it "accepts the host param" do
        host = 'localhost'
        Mongo::Connection.should_receive(:new).with(host, nil, {}).and_return(connection)
        MongoDoc.connect(host)
      end

      it "accepts the port param" do
        host = 'localhost'
        port = 3000
        Mongo::Connection.should_receive(:new).with(host, 3000, {}).and_return(connection)
        MongoDoc.connect(host, port)
      end

      it "accepts an options hash" do
        opts = {:slave_ok => true}
        Mongo::Connection.should_receive(:new).with(nil, nil, opts).and_return(connection)
        MongoDoc.connect(opts)
      end

      it "accepts host, port, and options" do
        host = 'localhost'
        port = 3000
        opts = {:slave_ok => true}
        Mongo::Connection.should_receive(:new).with(host, 3000, opts).and_return(connection)
        MongoDoc.connect(host, port, opts)
      end
    end

    context "when there is a config file" do
      before do
        MongoDoc.config_path = './spec/mongodb.yml'
        config = YAML.load_file(MongoDoc.config_path)
        @host = config['host']
        @port = config['port']
        @db_options = config['options']
      end

      context "with a host config file" do

        it "and no params connects to the database with the values from the file" do
          Mongo::Connection.should_receive(:new).with(@host, @port, @db_options).and_return(connection)
          MongoDoc.connect
        end

        it "and params connects to the database with the params" do
          host = 'p_host'
          port = 890
          options = {:option => 'p_opt'}
          Mongo::Connection.should_receive(:new).with(host, port, options).and_return(connection)
          MongoDoc.connect(host, port, options)
        end
      end

      context "with a host pairs config file" do
        before do
          MongoDoc.config_path = './spec/mongodb_pairs.yml'
          config = YAML.load_file(MongoDoc.config_path)
          @host_pairs = config['host_pairs']
          @port = config['port']
          @db_options = config['options']
        end

        it "connects to the database with the host pairs value from the file" do
          Mongo::Connection.should_receive(:new).with(@host_pairs, @port, @db_options).and_return(connection)
          MongoDoc.connect
        end
      end
    end
  end

  describe ".connect_to_database" do
    before do
      MongoDoc.database = nil
      MongoDoc.connection = nil
      MongoDoc.config = nil
    end

    it "raises a no database error when the database connect failed" do
      connection = stub("connection", :db => nil)
      MongoDoc.stub(:connect).and_return(connection)
      lambda {MongoDoc.connect_to_database}.should raise_error(MongoDoc::NoDatabaseError)
    end

    it "returns the database" do
      db = 'db'
      connection = stub("connection", :db => db)
      MongoDoc.stub(:connect).and_return(connection)
      MongoDoc.connect_to_database.should == db
    end

    context "when a connection exists" do
      before do
        @db = 'db'
        @connection = stub("connection", :db => @db)
      end

      it "uses the exsiting connection if already connected" do
        MongoDoc.should_receive(:connection).and_return(@connection)
        MongoDoc.should_not_receive(:connect)
        MongoDoc.connect_to_database.should == @db
      end

      it "connects if force connect is true" do
        MongoDoc.should_not_receive(:connection)
        MongoDoc.should_receive(:connect).and_return(@connection)
        MongoDoc.connect_to_database(nil, nil, nil, nil, true).should == @db
      end
    end

    context "when there is no config file" do
      before do
        MongoDoc.config_path = nil
        @db = 'db'
        @name = 'name'
        @connection = stub('connection')
      end

      it "connects with defaults when not given parameters" do
        @connection.should_receive(:db).with(@name).and_return(@db)
        MongoDoc.should_receive(:connect).and_return(@connection)
        MongoDoc.connect_to_database(@name)
      end

      it "connects with the given parameters" do
        host = 'host'
        port = 123
        options = { :auto_reconnect => true }
        @connection.should_receive(:db).with(@name).and_return(@db)
        MongoDoc.should_receive(:connect).with(host, port, options).and_return(@connection)
        MongoDoc.connect_to_database(@name, host, port, options)
      end
    end

    context "when there is a config file" do
      before do
        @db = 'db'
        MongoDoc.config_path = './spec/mongodb.yml'
        config = YAML.load_file(MongoDoc.config_path)
        @database = config['name']
        @host = config['host']
        @port = config['port']
        @db_options = config['options']
        @connection = stub('connection')
      end

      context "with a host config file" do

        it "without a name uses configured name" do
          @connection.should_receive(:db).with(@database).and_return(@db)
          MongoDoc.stub(:connect).and_return(@connection)
          MongoDoc.connect_to_database
        end

        it "and params connects to the database with the params" do
          database = 'p_database'
          host = 'p_host'
          port = 890
          options = {:option => 'p_opt'}
          @connection.should_receive(:db).with(database).and_return(@db)
          MongoDoc.should_receive(:connect).with(host, port, options).and_return(@connection)
          MongoDoc.connect_to_database(database, host, port, options)
        end
      end
    end
  end
end
