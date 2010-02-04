require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# Resets for testing
module MongoDoc
  def reset
    @config_path = nil
    @configuration = nil
    @connection = nil
    @database = nil
    @host = nil
    @name = nil
    @options = nil
    @port = nil
    @strict = nil
  end
end

describe "MongoDoc Connections" do

  it "default the configuration location to './mongodb.yml'" do
    MongoDoc.config_path.should == './mongodb.yml'
  end

  context "Non-rails environment" do

    it "does not see Rails" do
      Object.const_defined?('Rails').should be_false
    end

    context "without a configuration" do
      let(:connection) { stub('connection') }

      before do
        MongoDoc.reset
        MongoDoc.stub(:connect).and_return(connection)
      end

      it "creates a default connection" do
        MongoDoc.should_receive(:connect).and_return(connection)
        MongoDoc.connection
      end

      it "creates a default database with strict false" do
        connection.should_receive(:db).with("mongodoc", :strict => false)
        MongoDoc.database
      end
    end
  end

  context "Rails environment" do

    module FauxRails
      extend self

      def env
        'development'
      end
    end

    before do
      Object.const_set('Rails', FauxRails)
    end

    after do
      Object.send(:remove_const, 'Rails')
    end

    it "sees Rails" do
      Object.const_defined?('Rails').should be_true
    end

    context "without a configuration" do
      let(:connection) { stub('connection') }

      before do
        MongoDoc.reset
        MongoDoc.stub(:connect).and_return(connection)
      end

      it "creates a default connection" do
        MongoDoc.should_receive(:connect).and_return(connection)
        MongoDoc.connection
      end

      it "creates a default database with strict false" do
        connection.should_receive(:db).with("development", :strict => false)
        MongoDoc.database
      end
    end
  end

  context ".verify_server_version" do
    let(:connection) { stub('connection') }

    it "raises when the server version is unsupported" do
      connection.stub(:server_version).and_return(Mongo::ServerVersion.new('1.3.1'))
      lambda { MongoDoc.send(:verify_server_version, connection) }.should raise_error(MongoDoc::UnsupportedServerVersionError)
    end

    it "returns when the server version is supported" do
      connection.stub(:server_version).and_return(Mongo::ServerVersion.new('1.3.2'))
      lambda { MongoDoc.send(:verify_server_version, connection) }.should_not raise_error(MongoDoc::UnsupportedServerVersionError)
    end
  end

  describe ".connect" do
    let(:connection) { stub('connection') }

    before do
      MongoDoc.stub(:verify_server_version).and_return(true)
    end

    it "creates a Mongo::Connection" do
      host = 'host'
      port = 'port'
      options = 'options'
      MongoDoc.stub(:host).and_return(host)
      MongoDoc.stub(:port).and_return(port)
      MongoDoc.stub(:options).and_return(options)
      Mongo::Connection.should_receive(:new).with(host, port, options).and_return(connection)
      MongoDoc.send(:connect)
    end

    it "raises NoConnectionError if the connection fails" do
      Mongo::Connection.stub(:new).and_return(nil)
      lambda { MongoDoc.send(:connect) }.should raise_error(MongoDoc::NoConnectionError)
    end

    it "raises UnsupportedServerVersionError if the server version is unsupported" do
      Mongo::Connection.stub(:new).and_return(connection)
      MongoDoc.stub(:verify_server_version).and_raise(MongoDoc::UnsupportedServerVersionError)
      lambda { MongoDoc.send(:connect) }.should raise_error(MongoDoc::UnsupportedServerVersionError)
    end
  end
end
