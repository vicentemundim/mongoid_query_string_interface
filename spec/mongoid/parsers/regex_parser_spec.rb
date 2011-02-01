require 'spec_helper'

describe Mongoid::QueryStringInterface::Parsers::RegexParser do
  it "should be able to parse a regex" do
    should be_parseable('/\d*(.*)-[a-zA-Z]/', nil)
  end
  
  it "should be able to parse a regex with modifiers" do
    should be_parseable('/\d*(.*)-[a-zA-Z]/i', nil)
  end
  
  it "should not be able to parse a text" do
    should_not be_parseable('Anything else', nil)
  end
  
  it "should not be able to parse an invalid regex" do
    should_not be_parseable('/dasdasds', nil)
  end
  
  it "should parse a regex" do
    subject.parse('/\d*(.*)-[a-zA-Z]/').should == /\d*(.*)-[a-zA-Z]/
  end
  
  it "should parse a regex with modifiers" do
    subject.parse('/\d*(.*)-[a-zA-Z]/i').should == /\d*(.*)-[a-zA-Z]/i
  end
  
  it "should not parse an invalid regex" do
    subject.parse('/\d*(.*)-[a-zA-Z]').should be_nil
  end
end