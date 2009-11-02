require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoDoc::Document::ParentProxy" do
  class Parent
    def path_to_root(attrs)
      attrs
    end
  end

  before do
    @parent = Parent.new
    @assoc_name = 'association'
  end

  subject do
    MongoDoc::Document::ParentProxy.new(@parent, @assoc_name)
  end

  it "has the association name" do
    should respond_to(:assoc_name)
  end

  it "has a parent" do
    should respond_to(:_parent)
  end

  it "requires a parent" do
    expect do
      MongoDoc::Document::ParentProxy.new(nil, @assoc_name)
    end.should raise_error
  end

  it "requires an association name" do
    expect do
      MongoDoc::Document::ParentProxy.new(@parent, nil)
    end.should raise_error
  end

  it "inserts the association name the path_to_root" do
    subject.path_to_root({:name1 => 'value1', :name2 => 'value2'}).should == {"#{@assoc_name}.name1" => 'value1', "#{@assoc_name}.name2" => "value2"}
  end
end