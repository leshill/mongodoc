require File.expand_path(File.join(File.dirname(__FILE__), '..',  'spec_helper'))

describe "MongoDoc::Associations::ParentProxy" do
  class Parent
    include MongoDoc::Document
  end

  class Child
    include MongoDoc::Document
  end

  before do
    @parent = Parent.new
    @assoc_name = 'association'
  end

  subject do
    MongoDoc::Associations::ParentProxy.new(@parent, @assoc_name)
  end

  it "has the association name" do
    should respond_to(:assoc_name)
  end

  it "has a parent" do
    should respond_to(:_parent)
  end

  it "requires a parent" do
    expect do
      MongoDoc::Associations::ParentProxy.new(nil, @assoc_name)
    end.should raise_error
  end

  it "requires an association name" do
    expect do
      MongoDoc::Associations::ParentProxy.new(@parent, nil)
    end.should raise_error
  end

  it "inserts the association name the _path_to_root" do
    subject._path_to_root(Child.new, :name1 => 'value1', :name2 => 'value2').should == {"#{@assoc_name}.name1" => 'value1', "#{@assoc_name}.name2" => "value2"}
  end
end
