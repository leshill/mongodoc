require File.expand_path(File.join(File.dirname(__FILE__), '..',  'spec_helper'))

describe "MongoDoc::Associations::DocumentProxy" do
  class Parent
    include MongoDoc::Document
  end

  class Child
    include MongoDoc::Document
  end

  let(:parent) { Parent.new }
  let(:name) {'association'}

  subject do
    MongoDoc::Associations::DocumentProxy.new(:assoc_name => name, :root => parent, :parent => parent, :assoc_class => Child)
  end

  it "has the association name" do
    subject.assoc_name.should == name
  end

  it "has the parent" do
    subject._parent.should == parent
  end

  it "has the root" do
    subject._root.should == parent
  end

  it "has the association class" do
    subject.assoc_class.should == Child
  end

  it "#build builds a new object" do
    Child.should === subject.build({})
  end

  describe "#_path_to_root" do
    it "returns the parents path and our name" do
      parent.stub(:_path_to_root).and_return('parent')
      subject._path_to_root.should == "parent.association"
    end
  end

  describe "#_update_path_to_root" do
    it "returns the parents path and our name" do
      parent.stub(:_update_path_to_root).and_return('parent')
      subject._update_path_to_root.should == "parent.association"
    end
  end
end
