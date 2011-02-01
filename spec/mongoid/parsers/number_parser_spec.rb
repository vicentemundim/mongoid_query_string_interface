require 'spec_helper'

describe Mongoid::QueryStringInterface::Parsers::NumberParser do
  it "should be able to parse a valid integer" do
    Mongoid::QueryStringInterface::Parsers::NumberParser.should be_parseable('85910')
  end
  
  it "should be able to parse a valid float" do
    Mongoid::QueryStringInterface::Parsers::NumberParser.should be_parseable('3589.98161247777')
  end
  
  it "should not be able to parse a text" do
    Mongoid::QueryStringInterface::Parsers::NumberParser.should_not be_parseable('Anything else')
  end
  
  it "should not be able to parse an invalid integer" do
    Mongoid::QueryStringInterface::Parsers::NumberParser.should_not be_parseable('13albsa')
  end
  
  it "should not be able to parse an invalid float" do
    Mongoid::QueryStringInterface::Parsers::NumberParser.should_not be_parseable('2341.a31ds323')
  end
  
  it "should parse a valid integer" do
    Mongoid::QueryStringInterface::Parsers::NumberParser.parse('85910').should == 85910
  end
  
  it "should parse a valid float" do
    Mongoid::QueryStringInterface::Parsers::NumberParser.parse('3589.98161247777').should == 3589.98161247777
  end
end