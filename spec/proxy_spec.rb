require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe MongoDoc::Proxy do
  class ProxyTest < MongoDoc::Document
    key :name
  end

  let(:root) { stub('root', :register_save_observer => nil) }
  let(:proxy) { MongoDoc::Proxy.new(:assoc_name => 'has_many_name', :collection_class => ProxyTest, :root => root, :parent => root) }

  context "#<<" do
    let(:item) { ProxyTest.new }

    it "appends the item to the collection" do
      (proxy << item).should include(item)
    end

    context "when the item is a Hash" do
      let(:hash) {{:name => 'hash'}}

      it "calls build when the item is a hash" do
        proxy.should_receive(:build).with(hash).and_return(item)
        proxy << hash
      end

      it "registers a save observer" do
        proxy.stub(:build).and_return(item)
        root.should_receive(:register_save_observer)
        proxy << hash
      end

      it "sets the root" do
        proxy.stub(:build).and_return(item)
        proxy << hash
        item._root.should == root
      end
    end

    context "when the item is not a MongoDoc::Document" do
      it "does not register a save observer" do
        root.should_not_receive(:register_save_observer)
        proxy << 'not_doc'
      end

      it "does not set the root" do
        item.should_not_receive(:_root=)
        proxy << 'not_doc'
      end
    end

    context "when the item is a MongoDoc::Document" do
      it "registers a save observer" do
        root.should_receive(:register_save_observer)
        proxy << item
      end

      it "sets the root" do
        proxy << item
        item._root.should == root
      end
    end

    context "when the item is an array" do
      it "adds the array" do
        array = ['something else']
        proxy << array
        proxy.should include(array)
      end
    end
  end

  context "#build" do
    it "builds an object of the collection class from the hash attrs" do
      name = 'built'
      proxy.build({:name => name}).name.should == name
    end
  end
end
