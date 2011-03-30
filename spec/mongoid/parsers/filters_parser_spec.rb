require 'spec_helper'

describe Mongoid::QueryStringInterface::Parsers::FiltersParser do
  let :default_filters do
    { :status => 'published' }.with_indifferent_access
  end

  context "when no filters are given" do
    subject do
      described_class.new({}, default_filters)
    end

    it "should return the default filters" do
      subject.parse.should == default_filters
    end
  end

  context "when filters are given" do
    subject do
      described_class.new(filters, default_filters)
    end

    let :filters do
      { 'title' => 'Some Title' }.with_indifferent_access
    end

    it "should return the given filters merged with the default filters" do
      subject.parse.should == default_filters.merge(filters)
    end

    context "and they override the default filters" do
      let :filters do
        { 'title' => 'Some Title', 'status' => 'unpublished' }.with_indifferent_access
      end

      it "should return the given filters merged with the default filters, overriding the defaults" do
        subject.parse.should == default_filters.merge(filters)
      end
    end

    describe "with nested filters" do
      let :filters do
        { 'program.title' => 'Some Title' }.with_indifferent_access
      end

      it "should return the given filters merged with the default filters" do
        subject.parse.should == default_filters.merge(filters)
      end
    end

    describe "with conditional operators" do
      describe "appearing once for a field" do
        let :filters do
          { 'title.ne' => 'Some Title' }.with_indifferent_access
        end

        it "should properly parse it" do
          subject.parse.should == default_filters.merge({ 'title' => { '$ne' => 'Some Title' } })
        end
      end

      describe "appearing more than once for a field" do
        let :filters do
          { 'count.gte' => '1', 'count.lt' => '10' }.with_indifferent_access
        end

        it "should properly parse it" do
          subject.parse.should == default_filters.merge({ 'count' => { '$gte' => 1, '$lt' => 10 } })
        end
      end
    end

    describe "with $or operator" do
      let :filters do
        { 'or' => '[{"title": "Some Title"}, {"title": "Some Other Title"}]' }.with_indifferent_access
      end

      it "should properly parse it from the given JSON" do
        subject.parse.should == default_filters.merge({ '$or' => [{ 'title' => 'Some Title' }, { 'title' => 'Some Other Title' }] })
      end
    end
  end
end