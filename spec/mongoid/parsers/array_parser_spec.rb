require 'spec_helper'

describe Mongoid::QueryStringInterface::Parsers::ArrayParser do
  Mongoid::QueryStringInterface::ARRAY_CONDITIONAL_OPERATORS.each do |operator|
    it "should be parseable when operator is $#{operator}" do
      should be_parseable('any-value', "$#{operator}")
    end
  end
  
  it "should not be parseable when no operator is given" do
    should_not be_parseable('any-value', nil)
  end
  
  it "should not be parseable for invalid operator" do
    should_not be_parseable('any-value', '$gte')
  end
  
  it "should parse a single value" do
    subject.parse('Single Value').should == ['Single Value']
  end
  
  it "should parse an array of values" do
    subject.parse('A Value|Another Value|Yet another').should == ['A Value', 'Another Value', 'Yet another']
  end
  
  it "should strip values when parsing" do
    subject.parse('A Value   |   Another Value   |  Yet another').should == ['A Value', 'Another Value', 'Yet another']
  end
  
  it "should parse regex values in array" do
    subject.parse('A Value|/Another Value/|/Yet another/i').should == ['A Value', /Another Value/, /Yet another/i]
  end
end