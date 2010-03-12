require 'spec_helper'

describe "MongoDoc::Attributes attributes accessor" do
  class AttributesTest
    include MongoDoc::Attributes

    attr_accessor :name
    attr_accessor :age
    attr_accessor :birthdate, :type => Date
  end

  context "#attributes" do
    subject do
      AttributesTest.new.attributes
    end

    it "returns a hash of the given attributes" do
      should have_key(:name)
      should have_key(:age)
      should have_key(:birthdate)
    end
  end

  context "#attributes=" do
    let(:object) { AttributesTest.new }

    it "sets attributes from a hash" do
      name = 'name'
      object.attributes = {:name => name}
      object.name.should == name
    end
  end
end
