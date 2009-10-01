Then /the collection should have (\d+) documents?/ do |count|
  @collection.count.should == count.to_i
end