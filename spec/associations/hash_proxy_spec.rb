require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe MongoDoc::Associations::HashProxy do
  class HashProxyTest
    include MongoDoc::Document

    attr_accessor :name
  end

  let(:root) { stub('root', :register_save_observer => nil) }
  let(:proxy) { MongoDoc::Associations::HashProxy.new(:assoc_name => 'embed_hash_name', :assoc_class => HashProxyTest, :root => root, :parent => root) }
  let(:item) { HashProxyTest.new }
  let(:other_item) {[1,2]}

  context "#[]=" do
    it "adds the item to the hash" do
      proxy['new'] = item
      proxy['new'].should == item
    end

    context "key names must be a string or symbol constrained by BSON element name" do
      ['$invalid', 'in.valid', :_id, 'query', 1, Object.new].each do |name|
        it "#{name} is invalid" do
          expect do
            proxy[name] = other_item
          end.to raise_error(MongoDoc::InvalidEmbeddedHashKey)
        end
      end

      [:key, 'key'].each do |name|
        it "#{name} is a valid name" do
          expect do
            proxy[name] = other_item
          end.to_not raise_error(MongoDoc::InvalidEmbeddedHashKey)
        end
      end
    end

    context "when the item is not a MongoDoc::Document" do

      it "does not register a save observer" do
        root.should_not_receive(:register_save_observer)
        proxy['new'] = other_item
      end

      it "does not set the root" do
        other_item.should_not_receive(:_root=)
        proxy['new'] = other_item
      end
    end

    context "when the item is a MongoDoc::Document" do
      it "registers a save observer" do
        root.should_receive(:register_save_observer)
        proxy['new'] = item
      end

      it "sets the root" do
        proxy['new'] = item
        item._root.should == root
      end
    end
  end

  context "#merge!" do
    context "when the key value is not a MongoDoc::Document" do

      it "does not register a save observer" do
        root.should_not_receive(:register_save_observer)
        proxy.merge!(:new => other_item)
      end

      it "does not set the root" do
        other_item.should_not_receive(:_root=)
        proxy.merge!(:new => other_item)
      end
    end

    context "when the key value is a MongoDoc::Document" do
      it "registers a save observer" do
        root.should_receive(:register_save_observer)
        proxy.merge!(:new => item)
      end

      it "sets the root" do
        proxy.merge!(:new => item)
        item._root.should == root
      end
    end

    context "with a block" do
      it "calls into the block" do
        proxy.merge!(:new => other_item) {|k, v1, v2| @result = v2}
        @result.should == other_item
      end

      context "when the key value is not a MongoDoc::Document" do

        it "does not register a save observer" do
          root.should_not_receive(:register_save_observer)
          proxy.merge!(:new => other_item) {|k, v1, v2| v2}
        end

        it "does not set the root" do
          other_item.should_not_receive(:_root=)
          proxy.merge!(:new => other_item) {|k, v1, v2| v2}
        end
      end

      context "when the key value is a MongoDoc::Document" do
        it "registers a save observer" do
          root.should_receive(:register_save_observer)
          proxy.merge!(:new => item) {|k, v1, v2| v2}
        end

        it "sets the root" do
          proxy.merge!(:new => item) {|k, v1, v2| v2}
          item._root.should == root
        end
      end
    end
  end

  context "#replace" do
    it "clears any existing data" do
      proxy.should_receive(:clear)
      proxy.replace(:new => other_item)
    end

    context "when the key value is not a MongoDoc::Document" do

      it "does not register a save observer" do
        root.should_not_receive(:register_save_observer)
        proxy.replace(:new => other_item)
      end

      it "does not set the root" do
        other_item.should_not_receive(:_root=)
        proxy.replace(:new => other_item)
      end
    end

    context "when the key value is a MongoDoc::Document" do
      it "registers a save observer" do
        root.should_receive(:register_save_observer)
        proxy.replace(:new => item)
      end

      it "sets the root" do
        proxy.replace(:new => item)
        item._root.should == root
      end
    end

  end

  context "#build" do
    it "builds an object of the collection class from the hash attrs" do
      name = 'built'
      proxy.build(:key, {:name => name}).name.should == name
    end
  end
end
