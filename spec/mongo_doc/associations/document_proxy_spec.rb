require 'spec_helper'

describe "MongoDoc::Associations::DocumentProxy" do
  class Parent
    include MongoDoc::Document
  end

  class Child
    include MongoDoc::Document
  end

  let(:parent) { Parent.new }
  let(:name) {'association_name'}

  subject do
    MongoDoc::Associations::DocumentProxy.new(:assoc_name => name, :root => parent, :parent => parent, :assoc_class => Child)
  end

  describe "#build" do
    it "#build builds a new object" do
      Child.should === subject.build({})
    end
  end

  context "delegated to the document" do
    %w(id to_bson).each do |method|
      it "delegates #{method} to the document" do
        subject.stub(:document => stub)
        subject.document.should_receive(method)
        subject.send(method)
      end
    end
  end

  %w(_modifier_path= _selector_path=).each do |setter|
    describe "##{setter}" do
      it "delegates to the document with our assoc name" do
        subject.stub(:document => stub)
        subject.document.should_receive(setter).with("new.path.#{name}")
        MongoDoc::Associations::ProxyBase.stub(:is_document?).and_return(true)
        subject.send("#{setter}", 'new.path')
      end
    end
  end
end
