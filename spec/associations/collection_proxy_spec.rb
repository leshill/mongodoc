require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe MongoDoc::Associations::CollectionProxy do
  class CollectionProxyTest
    include MongoDoc::Document

    attr_accessor :name
  end

  let(:root) { CollectionProxyTest.new }
  let(:proxy) { MongoDoc::Associations::CollectionProxy.new(:assoc_name => 'embed_many_name', :assoc_class => CollectionProxyTest, :root => root, :parent => root) }
  let(:item) { CollectionProxyTest.new }

  describe "#_update_path_to_root" do
    it "returns the parents path and our name and '$'" do
      root.stub(:_update_path_to_root).and_return('parent')
      proxy._update_path_to_root.should == "parent.embed_many_name.$"
    end
  end

  context "#<<" do
    it "appends the item to the collection" do
      (proxy << item).should include(item)
    end

    context "when the item is a Hash" do
      let(:hash) {{:name => 'hash'}}

      it "does not register a save observer" do
        root.should_not_receive(:register_save_observer)
        proxy << hash
      end

      it "does not set the root" do
        hash.should_not_receive(:_root=)
        proxy << hash
      end

      it "adds the hash to the collection" do
        proxy << hash
        proxy.should include(hash)
      end
    end

    context "when the item is not a MongoDoc::Document" do
      let(:other_item) {'not a doc'}

      it "does not register a save observer" do
        root.should_not_receive(:register_save_observer)
        proxy << other_item
      end

      it "does not set the root" do
        other_item.should_not_receive(:_root=)
        proxy << other_item
      end

      it "adds the item to the collection" do
        proxy << other_item
        proxy.should include(other_item)
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

  context "#[]=" do
    it "sets the item at the index" do
      proxy[1] = item
      proxy[1].should == item
    end

    context "when the item is not a MongoDoc::Document" do
      let(:other_item) {'not a doc'}

      it "does not register a save observer" do
        root.should_not_receive(:register_save_observer)
        proxy[1] = other_item
      end

      it "does not set the root" do
        other_item.should_not_receive(:_root=)
        proxy[1] = other_item
      end

      it "adds the item to the collection" do
        proxy[1] = other_item
        proxy.should include(other_item)
      end
    end

    context "when the item is a MongoDoc::Document" do
      it "registers a save observer" do
        root.should_receive(:register_save_observer)
        proxy[1] = item
      end

      it "sets the root" do
        proxy[1] = item
        item._root.should == root
      end
    end
  end

  context "#concat" do
    it "appends the items from the array to self" do
      proxy.concat([item])
      proxy.should include(item)
    end
  end

  context "#replace" do
    it "clears the existing collection" do
      proxy.should_receive(:clear)
      proxy.replace([item])
    end

    it "concats the other onto self" do
      other = [item]
      proxy.should_receive(:concat).with(other)
      proxy.replace(other)
    end
  end

  context "#unshift" do
    let(:proxy_with_item) { proxy << 'other' }

    it "adds the item to the front of the collection" do
      proxy_with_item.unshift(item)
      proxy_with_item[0].should == item
    end

    context "when the item is not a MongoDoc::Document" do
      let(:other_item) {'not a doc'}

      it "does not register a save observer" do
        root.should_not_receive(:register_save_observer)
        proxy_with_item.unshift(other_item)
      end

      it "does not set the root" do
        other_item.should_not_receive(:_root=)
        proxy_with_item.unshift(other_item)
      end

      it "adds the item to the front of the collection" do
        proxy_with_item.unshift(other_item)
        proxy_with_item[0].should == other_item
      end
    end

    context "when the item is a MongoDoc::Document" do
      let(:new_item) { CollectionProxyTest.new }

      it "registers a save observer" do
        root.should_receive(:register_save_observer)
        proxy_with_item.unshift(new_item)
      end

      it "sets the root" do
        proxy_with_item.unshift(new_item)
        new_item._root.should == root
      end

      it "adds the item to the front of the collection" do
        proxy_with_item.unshift(new_item)
        proxy_with_item[0].should == new_item
      end
    end
  end

  context "#build" do
    let(:name) {'built'}

    it "adds a built item to the collection" do
      proxy.build({:name => name}).last.name.should == name
    end

    it "registers a save observer" do
      root.should_receive(:register_save_observer)
      proxy.build({:name => name})
    end

    it "sets the root" do
      proxy.build({:name => name})
      proxy.last._root.should == root
    end
  end
end
