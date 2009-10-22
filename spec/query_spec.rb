require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Query support for MongoDoc" do
  describe "#set_modifier" do
    it "modifies all simple key/values of the hash to a set modifier" do
      key = 'key'
      value = 'value'
      hash = {key => value}
      MongoDoc::Query.set_modifier(hash).should == {'$set' => hash}
    end
  end
end