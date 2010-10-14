Given /^a new connection to the database "([^"]*)" with user "([^"]*)" and password "([^"]*)"$/ do |db, user, password|
  begin
    MongoDoc::Connection.connection = Mongo::Connection.from_uri("mongodb://#{user}:#{password}@localhost/#{db}")
    MongoDoc::Connection.send(:verify_server_version)
  rescue StandardError => e
    @exception = e
  end
end

Then /^a "([^"]*)" exception is thrown$/ do |exception|
  @exception.class.name.should == exception
end

