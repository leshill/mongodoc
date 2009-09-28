require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoDoc Connections" do

  it ".connection raises a no connection error when connect has not been called" do
    lambda {MongoDoc.connection}.should raise_error(MongoDoc::NoConnectionError)
  end
  
  describe ".connect" do
    it "when called with no params just connects" do
      Mongo::Connection.should_receive(:new)
      MongoDoc.connect
    end
    
    describe "mimics the Mongo::Connection API" do
      it "accepts the host param" do
        host = 'localhost'
        Mongo::Connection.should_receive(:new).with(host, nil, {})
        MongoDoc.connect(host)
      end

      it "accepts the port param" do
        host = 'localhost'
        port = 3000
        Mongo::Connection.should_receive(:new).with(host, 3000, {})
        MongoDoc.connect(host, port)
      end
      
      it "accepts an options hash" do
        opts = {:slave_ok => true}
        Mongo::Connection.should_receive(:new).with(nil, nil, opts)
        MongoDoc.connect(opts)
      end
      
      it "accepts host, port, and options" do
        host = 'localhost'
        port = 3000
        opts = {:slave_ok => true}
        Mongo::Connection.should_receive(:new).with(host, 3000, opts)
        MongoDoc.connect(host, port, opts)
      end
    end
    
    it "sets the connection" do
      cnx = 'connection'
      Mongo::Connection.should_receive(:new).and_return(cnx)
      MongoDoc.connect
      MongoDoc.connection.should == cnx
    end
  end
  
  describe ".database" do
    it "raises a no database error when the database has not been initialized" do
      lambda {MongoDoc.database}.should raise_error(MongoDoc::NoDatabaseError)
    end

    it "returns the current database when not given any arguments" do
      db = 'db'
      MongoDoc.send(:class_variable_set, :@@database, db)
      MongoDoc.database.should == db
    end
    
    it "connects to the database when no passed any additional arguments" do
      name = 'name'
      cnx = stub('connection')
      cnx.should_receive(:db).with(name)
      MongoDoc.should_receive(:connection).and_return(cnx)
      MongoDoc.database(name)
    end
    
    it "sets the database when called with the name parameter" do
      db = 'db'
      name = 'name'
      cnx = stub('connection')
      cnx.should_receive(:db).with(name).and_return(db)
      MongoDoc.should_receive(:connection).and_return(cnx)
      MongoDoc.database(name)
      MongoDoc.database.should == db
    end
  end
end