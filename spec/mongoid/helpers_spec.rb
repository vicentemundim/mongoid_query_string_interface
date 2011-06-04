require 'spec_helper'

class Document
  include Mongoid::QueryStringInterface::Helpers
end

describe Mongoid::QueryStringInterface::Helpers do

  let :subject do
    Document.new
  end

  it "should return a HashWithIndifferentAccess for a common hash" do
    subject.hash_with_indifferent_access({}).should be_instance_of(::HashWithIndifferentAccess)
  end

  it "should return the same object if it is already a HashWithIndifferentAccess" do
    hash = HashWithIndifferentAccess.new :key => :value
    subject.hash_with_indifferent_access(hash).should == hash
  end

  it "should return the attribute name if isn't present on hash" do
    subject.replace_attribute(:key, {:key2 => :new_key}).should == :key
  end

  it "should return the new attribute name if is present on hash" do
    subject.replace_attribute(:key, {:key => :new_key}).should == :new_key
  end

end
