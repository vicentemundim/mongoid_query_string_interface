require 'spec_helper'

describe Mongoid::QueryStringInterface::Parsers::NumberParser do
  it "should be able to parse a valid integer" do
    should be_parseable('85910', nil)
  end
  
  it "should be able to parse a valid float" do
    should be_parseable('3589.98161247777', nil)
  end
  
  it "should not be able to parse a text" do
    should_not be_parseable('Anything else', nil)
  end
  
  it "should not be able to parse an invalid integer" do
    should_not be_parseable('13albsa', nil)
  end
  
  it "should not be able to parse an invalid float" do
    should_not be_parseable('2341.a31ds323', nil)
  end
  
  it "should parse a valid integer" do
    subject.parse('85910').should == 85910
  end
  
  it "should parse a valid float" do
    subject.parse('3589.98161247777').should == 3589.98161247777
  end
end