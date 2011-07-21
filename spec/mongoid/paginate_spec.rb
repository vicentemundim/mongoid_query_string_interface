require 'spec_helper'

class Document
  include Mongoid::Document
  extend Mongoid::Paginate

  field :title
end

describe Mongoid::Paginate do
  let(:total_entries) { 30 }

  let! :documents do
    total_entries.times.map { |i| Document.create(:title => "Doc #{i}") }
  end

  describe ".paginate" do
    it "should return a WillPaginate::Collection" do
      Document.paginate.should be_a(WillPaginate::Collection)
    end

    it "should return an array with 20 documents per page of the first page by default" do
      Document.paginate.should == documents[0..19]
    end

    it "should return an array with the specified documents per page of the first page" do
      Document.paginate(:per_page => 5).should == documents[0..4]
    end

    it "should return an array with the specified documents per page of the specified page" do
      Document.paginate(:per_page => 5, :page => 3).should == documents[10..14]
    end

    it "should return an array with the specified documents per page as string of the specified page as string" do
      Document.paginate(:per_page => '5', :page => '3').should == documents[10..14]
    end

    it "should return an array with the total entries" do
      Document.paginate(:per_page => 5, :page => 3).total_entries.should == total_entries
    end
  end
end