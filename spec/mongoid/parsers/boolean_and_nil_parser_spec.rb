require 'spec_helper'

describe Mongoid::QueryStringInterface::Parsers::BooleanAndNilParser do
  it "should be able to parse a boolean true" do
    should be_parseable('true', nil)
  end
  
  it "should be able to parse a boolean false" do
    should be_parseable('false', nil)
  end
  
  it "should be able to parse nil" do
    should be_parseable('nil', nil)
  end
  
  it "should be able to parse null" do
    should be_parseable('null', nil)
  end
  
  it "should be able to parse any other text" do
    should be_parseable('some text', nil)
  end
  
  it "should not be able to parse an empty value" do
    should_not be_parseable('', nil)
  end
  
  it "should parse a boolean 'true' as true" do
    subject.parse('true').should be_true
  end
  
  it "should parse a boolean 'true' as false" do
    subject.parse('false').should be_false
  end
  
  it "should parse nil" do
    subject.parse('nil').should be_nil
  end
  
  it "should parse null" do
    subject.parse('null').should be_nil
  end
  
  it "should strip true value before parsing" do
    subject.parse(' true  ').should be_true
  end
  
  it "should strip false value before parsing" do
    subject.parse(' false').should be_false
  end
  
  it "should strip nil value before parsing" do
    subject.parse(' nil').should be_nil
  end
  
  it "should strip null value before parsing" do
    subject.parse(' null').should be_nil
  end
  
  it "should return the given value if it is not nil or null" do
    subject.parse('some text').should == 'some text'
  end
  
  it "should parse an empty value as nil" do
    subject.parse('').should be_nil
  end
  
  it "should parse a nil value as nil" do
    subject.parse(nil).should be_nil
  end
end