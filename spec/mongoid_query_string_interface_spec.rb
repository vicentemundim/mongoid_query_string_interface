require 'spec_helper'

class Document
  include Mongoid::Document
  extend Mongoid::QueryStringInterface
  
  field :title
  field :some_integer, :type => Integer
  field :some_float, :type => Float
  field :created_at, :type => Time
  field :tags, :type => Array
  field :status
  
  embeds_one :embedded_document
  
  def self.default_filtering_options
    { :status => 'published' }
  end
  
  def self.default_sorting_options
    [:created_at.desc]
  end
end

class EmbeddedDocument
  include Mongoid::Document
  
  field :name
  field :tags, :type => Array
  
  embedded_in :document, :inverse_of => :embedded_document
end

describe Mongoid::QueryStringInterface do
  let :document do
    Document.create :title => 'Some Title', :some_integer => 1, :some_float => 1.1, :status => 'published',
                    :created_at => 5.days.ago.to_time, :tags => ['esportes', 'basquete', 'flamengo'],
                    :embedded_document => { :name => 'embedded document',
                      :tags => ['bar', 'foo', 'yeah'] }
  end
  
  let :other_document do
    Document.create :title => 'Some Other Title', :some_integer => 2, :some_float => 2.2, :status => 'published',
                    :created_at => 2.days.ago.to_time, :tags => ['esportes', 'futebol', 'jabulani', 'flamengo'],
                    :embedded_document => { :name => 'other embedded document',
                      :tags => ['yup', 'uhu', 'yeah', 'H4', '4H', '4H4', 'H4.1', '4.1H', '4.1H4.1'] }
  end
  
  before :each do
    # creates the document and other document
    document and other_document
  end
  
  context 'with default filtering options' do
    it 'should use the default filtering options' do
      Document.create :status => 'not published' # this should not be retrieved
      Document.filter_by.should == [other_document, document]
    end
  end
  
  context 'with default sorting options' do
    it 'should use the default sorting options if no sorting option is given' do
      Document.filter_by.should == [other_document, document]
    end

    it 'should use the given sorting options and ignore the default sorting options' do
      Document.should_not_receive(:default_sorting_options)
      Document.filter_by('created_at.asc' => nil).should == [document, other_document]
    end
  end
  
  context 'with pagination' do
    before :each do
      @context = mock('context')
      Document.stub!(:where).and_return(@context)
      @context.stub!(:order_by).and_return(@context)
    end
    
    it 'should paginate the result by default' do
      @context.should_receive(:paginate).with('page' => 1, 'per_page' => 12)
      Document.filter_by
    end
    
    it 'should use the page and per_page parameters if they are given' do
      @context.should_receive(:paginate).with('page' => 3, 'per_page' => 20)
      Document.filter_by 'page' => 3, 'per_page' => 20
    end
  end
  
  context 'with sorting' do
    it 'should use order_by parameter to sort' do
      Document.filter_by('order_by' => 'created_at.desc').should == [other_document, document]
    end
    
    it 'should use asc as default if only the attribute name is given' do
      Document.filter_by('order_by' => 'created_at').should == [document, other_document]
    end
    
    it 'should use parameters with .desc modifiers to add sort options' do
      Document.filter_by('created_at.desc' => nil).should == [other_document, document]
    end
    
    it 'should use parameters with desc value to add sort options' do
      Document.filter_by('created_at' => 'desc').should == [other_document, document]
    end
    
    it 'should use parameters with .asc modifiers to add sort options' do
      Document.filter_by('created_at.asc' => nil).should == [document, other_document]
    end
    
    it 'should use parameters with asc value to add sort options' do
      Document.filter_by('created_at' => 'asc').should == [document, other_document]
    end
  end
  
  context 'with filtering' do
    it 'should use a simple filter on a document attribute' do
      Document.filter_by('title' => document.title).should == [document]
    end
    
    it 'should use a complex filter in an embedded document attribute' do
      Document.filter_by('embedded_document.name' => document.embedded_document.name).should == [document]
    end
    
    it 'should ignore pagination parameters' do
      Document.filter_by('title' => document.title, 'page' => 1, 'per_page' => 20).should == [document]
    end
    
    it 'should ignore order_by parameters' do
      Document.filter_by('title' => document.title, 'order_by' => 'created_at').should == [document]
    end
    
    it 'should ignore parameters with .asc' do
      Document.filter_by('title' => document.title, 'created_at.asc' => nil).should == [document]
    end
    
    it 'should ignore parameters with .desc' do
      Document.filter_by('title' => document.title, 'created_at.desc' => nil).should == [document]
    end
    
    it 'should ignore parameters with asc value' do
      Document.filter_by('title' => document.title, 'created_at' => 'asc').should == [document]
    end
    
    it 'should ignore parameters with desc value' do
      Document.filter_by('title' => document.title, 'created_at' => 'desc').should == [document]
    end
    
    it 'should ignore controller, action and format parameters' do
      Document.filter_by('title' => document.title, 'controller' => 'documents', 'action' => 'index', 'format' => 'json').should == [document]
    end
    
    it 'should accept simple regex values' do
      Document.filter_by('title' => '/ome Tit/').should == [document]
    end
    
    it 'should accept regex values with modifiers' do
      Document.filter_by('title' => '/some title/i').should == [document]
    end
    
    context 'with conditional operators' do
      it 'should use it when given as the last portion of attribute name' do
        Document.filter_by('title.ne' => 'Some Other Title').should == [document]
      end
      
      it 'should accept different conditional operators for the same attribute' do
        Document.filter_by('created_at.gt' => 6.days.ago.to_s, 'created_at.lt' => 4.days.ago.to_s).should == [document]
      end
      
      context 'with date values' do
        it 'should parse a date correctly' do
          Document.filter_by('created_at' => document.created_at.to_s).should == [document]
        end
      end
      
      context 'with number values' do
        it 'should parse a integer correctly' do
          Document.filter_by('some_integer.lt' => '2').should == [document]
        end
        
        it 'should not parse as an integer if it does not starts with a digit' do
          Document.filter_by('embedded_document.tags' => 'H4').should == [other_document]
        end

        it 'should not parse as an integer if it does not ends with a digit' do
          Document.filter_by('embedded_document.tags' => '4H').should == [other_document]
        end

        it 'should not parse as an integer if it has a non digit character in it' do
          Document.filter_by('embedded_document.tags' => '4H4').should == [other_document]
        end

        it 'should parse a float correctly' do
          Document.filter_by('some_float.lt' => '2.1').should == [document]
        end
        
        it 'should not parse as a float if it does not starts with a digit' do
          Document.filter_by('embedded_document.tags' => 'H4.1').should == [other_document]
        end

        it 'should not parse as a float if it does not ends with a digit' do
          Document.filter_by('embedded_document.tags' => '4.1H').should == [other_document]
        end

        it 'should not parse as a float if it has a non digit character in it' do
          Document.filter_by('embedded_document.tags' => '4.1H4.1').should == [other_document]
        end
      end
      
      context 'with regex values' do
        it 'should accept simple regex values' do
          Document.filter_by('title.in' => '/ome Tit/').should == [document]
        end

        it 'should accept regex values with modifiers' do
          Document.filter_by('title.in' => '/some title/i').should == [document]
        end
      end
      
      context 'with array values' do
        let :document_with_similar_tags do
          Document.create :title => 'Some Title', :some_number => 1, :status => 'published',
                          :created_at => 5.days.ago.to_time, :tags => ['esportes', 'basquete', 'flamengo', 'rede globo', 'esporte espetacular']
        end
        
        it 'should convert values into arrays for operator $all' do
          Document.filter_by('tags.all' => document.tags.join('|')).should == [document]
        end
        
        it 'should convert values into arrays for operator $in' do
          Document.filter_by('tags.in' => 'basquete|futebol').should == [other_document, document]
        end
        
        it 'should convert values into arrays for operator $nin' do
          Document.create :tags => ['futebol', 'esportes'], :status => 'published' # should not be retrieved
          Document.filter_by('tags.nin' => 'jabulani|futebol').should == [document]
        end
        
        it 'should convert single values into arrays for operator $all' do
          Document.filter_by('tags.all' => 'basquete').should == [document]
        end
        
        it 'should convert single values into arrays for operator $in' do
          Document.filter_by('tags.in' => 'basquete').should == [document]
        end
        
        it 'should convert single values into arrays for operator $nin' do
          Document.filter_by('tags.nin' => 'jabulani').should == [document]
        end
        
        it 'should accept different conditional operators for the same attribute' do
          document_with_similar_tags
          Document.filter_by('tags.all' => 'esportes|basquete', 'tags.nin' => 'rede globo|esporte espetacular').should == [document]
        end
      end
    end
  end
  
  describe 'when returning paginated collection' do
    it 'should return a paginated collection' do
      Document.paginated_collection_with_filter_by.should == {:total_entries => 2, :total_pages => 1, :per_page => 12, :offset => 0, :previous_page => nil, :current_page => 1, :next_page => nil}
    end
    
    it 'should accept filtering options' do
      context = mock('context', :count => 1)
      Document.should_receive(:where).with({:status => 'published', :title => document.title}).and_return(context)
      Document.paginated_collection_with_filter_by(:title => document.title).should == {:total_entries => 1, :total_pages => 1, :per_page => 12, :offset => 0, :previous_page => nil, :current_page => 1, :next_page => nil}
    end
    
    it 'should use pagination options' do
      context = mock('context', :count => 100)
      Document.should_receive(:where).with({:status => 'published'}).and_return(context)
      Document.paginated_collection_with_filter_by(:page => 3, :per_page => 20).should == {:total_entries => 100, :total_pages => 5, :per_page => 20, :offset => 40, :previous_page => 2, :current_page => 3, :next_page => 4}
    end
  end
end