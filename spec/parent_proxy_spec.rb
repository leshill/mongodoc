require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoDoc::Document::ParentProxy" do
  class Parent
    def path_to_root(attrs)
      attrs
    end
  end

  subject do
    @parent = Parent.new
    @assoc_name = 'association'
    MongoDoc::Document::ParentProxy.new(@parent, @assoc_name)
  end

  it "has the association name" do
    should respond_to(:assoc_name)
  end

  it "has a parent" do
    should respond_to(:_parent)
  end

  it "inserts the association name the path_to_root" do
    attrs = {:name => 'value'}
    subject.path_to_root(:name => 'value').should == {@assoc_name => attrs}
  end
end