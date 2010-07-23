require 'spec_helper'

describe MongoDoc::PolymorphicCollection do

  class BaseCollectionName
    include MongoDoc::Document

    attr_accessor :base
  end

  class SubCollectionName < BaseCollectionName
    attr_accessor :sub
  end

  class OverriddenCollectionName < BaseCollectionName
    collection_name :overridden
    attr_accessor :over
  end

  class TwoSubCollectionName < OverriddenCollectionName
    attr_accessor :two_sub
  end

  describe BaseCollectionName do
    it "uses the default collection_name for base doc" do
      BaseCollectionName.collection_name.should == BaseCollectionName.to_s.tableize.gsub('/', '.')
    end
  end

  describe SubCollectionName do
    it "uses the base's collection_name for the derived doc" do
      SubCollectionName.collection_name.should == BaseCollectionName.to_s.tableize.gsub('/', '.')
    end
  end

  describe OverriddenCollectionName do
    it "sets the collection_name to the overridden name" do
      OverriddenCollectionName.collection_name.should == 'overridden'
    end
  end

  describe TwoSubCollectionName do
    it "climbs the inheritance chain looking for the collection name" do
      TwoSubCollectionName.collection_name.should == 'overridden'
    end
  end
end
