require 'spec_helper'

describe Mongoid::QueryStringInterface::Parsers::DateTimeParser do
  it "should be able to parse a valid date" do
    should be_parseable('20101010')
  end
  
  it "should be able to parse a valid date time" do
    should be_parseable('2010-10-10T10:50:30')
  end
  
  it "should not be able to parse a text" do
    should_not be_parseable('Anything else')
  end
  
  it "should not be able to parse an invalid date format" do
    should_not be_parseable('20:asd:200 20/1/300')
  end
  
  it "should parse a valid date" do
    subject.parse('20101010').should == Time.parse('20101010')
  end
  
  it "should parse a valid date time" do
    subject.parse('2010-10-10T10:50:30').should == Time.parse('2010-10-10T10:50:30')
  end
end