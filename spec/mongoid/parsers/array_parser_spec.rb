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

  it "should parse nil values in array" do
    subject.parse('nil|null').should == [nil, nil]
  end

  it "should parse boolean values in array" do
    subject.parse('true|false').should == [true, false]
  end

  it "should parse integer values in array" do
    subject.parse('1|23|456').should == [1, 23, 456]
  end

  it "should parse float values in array" do
    subject.parse('1.2|34.5|678.901').should == [1.2, 34.5, 678.901]
  end

  it "should parse date values in array" do
    subject.parse('2010-11-01|2009-08-03').should == [Time.parse("2010-11-01"), Time.parse("2009-08-03")]
  end

  it "should parse date values in array" do
    subject.parse('2010-11-01T03:24:47Z|2009-05-28T03:24:47 -03:00').should == [Time.parse("2010-11-01T03:24:47Z"), Time.parse("2009-05-28T03:24:47 -03:00")]
  end

  it "should parse mixed values in array" do
    subject.parse('1.2|345|Some String|/[\d+] some regex/i|2010-11-01T03:24:47Z').should == [1.2, 345, 'Some String', /[\d+] some regex/i, Time.parse("2010-11-01T03:24:47Z")]
  end
end