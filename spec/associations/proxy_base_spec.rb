require 'spec_helper'

describe "MongoDoc::Associations::ProxyBase" do
  class ProxyBaseTest
    include MongoDoc::Associations::ProxyBase
  end

  let(:_assoc_class) { 'ClassOfAssociation' }
  let(:_assoc_name) { 'name_of_association' }
  let(:_root) { 'root of document' }
  let(:path) { 'root.parent' }

  subject do
    ProxyBaseTest.new({ :path => path, :assoc_class => _assoc_class, :assoc_name => _assoc_name, :root => _root })
  end

  %w(_assoc_class _assoc_name _modifier_path _root _selector_path).each do |attr|
    it "defines #{attr}" do
      should respond_to(attr)
    end
  end

  describe "#initialize" do
    %w(_assoc_class _assoc_name _root).each do |attr|
      its(attr) { should == send(attr) }
    end
  end

  describe "#_modifier_path" do
    its(:_modifier_path) { should == path + '.' + _assoc_name }
  end

  describe "#_modifier_path=" do
    it "sets the modifier path to the path + '.' + the assoc name" do
      subject._modifier_path = 'new_path'
      subject._modifier_path.should == "new_path.#{_assoc_name}"
    end
  end

  describe "#_selector_path" do
    its(:_selector_path) { should == path + '.' + _assoc_name }
  end

  describe "#_selector_path=" do
    it "sets the selector path to the path + '.' + the assoc name" do
      subject._selector_path = 'new_path'
      subject._selector_path.should == "new_path.#{_assoc_name}"
    end
  end

  describe ".is_document" do
    class TestIsDocument
      include MongoDoc::Document
    end

    it "returns false for any non-Document" do
      MongoDoc::Associations::ProxyBase.is_document?(Object.new).should be_false
    end

    it "returns true for any Document" do
      MongoDoc::Associations::ProxyBase.is_document?(TestIsDocument.new).should be_true
    end
  end

  describe "#attach" do
    class AttachDocument
      include MongoDoc::Document
    end

    let(:doc) { AttachDocument.new }
    let(:object) { Object.new }
    let(:proxy) { ProxyBaseTest.new(:assoc_class => _assoc_class, :assoc_name => _assoc_name, :root => _root) }

    it "returns the attached object" do
      proxy.send(:attach, object).should == object
    end

    context "when a Document" do
      it "attaches the Document" do
        proxy.should_receive(:attach_document)
        proxy.send(:attach, doc)
      end
    end

    context "when not a Document" do
      it "does not attach the Document" do
        proxy.should_not_receive(:attach_document)
        proxy.send(:attach, object)
      end
    end
  end
end
