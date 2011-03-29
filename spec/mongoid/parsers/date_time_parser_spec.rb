require 'spec_helper'

describe Mongoid::QueryStringInterface::Parsers::DateTimeParser do
  it "should not be able to parse a text" do
    should_not be_parseable('Anything else', nil)
  end
  
  it "should not be able to parse an invalid date format" do
    should_not be_parseable('20:asd:200 20/1/300', nil)
  end

  SAMPLE_DATES = [
    "2010-10-10",
    "2010-10-10T10:50:30",
    "2010-10-10T10:50:30Z",
    "2010-10-10T10:50:30-03:00",
    "2010-10-10T10:50:30 -03:00",
    "2010-10-10T10:50:30-0300",
    "2010-10-10T10:50:30 -0300"
  ]
  
  SAMPLE_DATES.each do |time|
    it "should be able to parse #{time}" do
      should be_parseable(time, nil)
    end

    it "should parse #{time}" do
      subject.parse(time).should == Time.parse(time)
    end
  end
end