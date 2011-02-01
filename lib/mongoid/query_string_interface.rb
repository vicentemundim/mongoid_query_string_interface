require File.expand_path(File.join('parsers', 'date_time_parser'), File.dirname(__FILE__))
require File.expand_path(File.join('parsers', 'number_parser'), File.dirname(__FILE__))
require File.expand_path(File.join('parsers', 'array_parser'), File.dirname(__FILE__))
require File.expand_path(File.join('parsers', 'regex_parser'), File.dirname(__FILE__))
require File.expand_path(File.join('parsers', 'boolean_and_nil_parser'), File.dirname(__FILE__))

module Mongoid
  module QueryStringInterface
    CONDITIONAL_OPERATORS = [:all, :exists, :gte, :gt, :in, :lte, :lt, :ne, :nin, :size, :near, :within]
    SORTING_OPERATORS = [:asc, :desc]
    
    PARSERS = [
      Mongoid::QueryStringInterface::Parsers::DateTimeParser.new,
      Mongoid::QueryStringInterface::Parsers::NumberParser.new,
      Mongoid::QueryStringInterface::Parsers::ArrayParser.new,
      Mongoid::QueryStringInterface::Parsers::RegexParser.new,
      Mongoid::QueryStringInterface::Parsers::BooleanAndNilParser.new
    ]
    
    def filter_by(params={})
      params = hash_with_indifferent_access(params)
      filter_only_by(params).order_by(*sorting_options(params)).paginate(pagination_options(params))
    end
    
    def filter_only_by(params={})
      where(filtering_options(hash_with_indifferent_access(params)))
    end

    def paginated_collection_with_filter_by(params={})
      params = hash_with_indifferent_access(params)
  
      pagination = pagination_options(params)
      pager = WillPaginate::Collection.new pagination[:page], pagination[:per_page], where(filtering_options(params)).count
  
      [:total_entries, :total_pages, :per_page, :offset, :previous_page, :current_page, :next_page].inject({}) do |result, attr|
        result[attr] = pager.send(attr)
        result
      end
    end

    def default_filtering_options
      {}
    end

    def default_sorting_options
      []
    end

    private
      def pagination_options(options)
        options.reverse_merge :per_page => 12, :page => 1
      end
  
      def filtering_options(options)
        default_filtering_options.merge(parse_operators(only_filtering(options)))
      end
  
      def sorting_options(options)
        options = only_sorting(options)

        sorting_options = []
        sorting_options.concat(parse_order_by(options))
        sorting_options.concat(parse_sorting(options))      
    
        sorting_options.empty? ? default_sorting_options : sorting_options
      end
  
      def parse_operators(options)
        options.inject({}) do |result, item|
          key, value = item
      
          attribute = attribute_from(key)
          operator = operator_from(key)
          value = parse_value(unescape(value), operator)

          if operator
            filter = { operator => value }

            if result.has_key?(attribute)
              result[attribute].merge!(filter)
            else
              result[attribute] = filter
            end
          else
            result[attribute] = value
          end
      
          result
        end
      end
  
      def attribute_from(key)
        if match = key.match(/(.*)\.(#{(CONDITIONAL_OPERATORS + SORTING_OPERATORS).join('|')})/)
          match[1].to_sym
        else
          key.to_sym
        end
      end
  
      def operator_from(key)
        if match = key.match(/.*\.(#{CONDITIONAL_OPERATORS.join('|')})/)
          "$#{match[1]}".to_sym
        end
      end
      
      def unescape(value)
        URI.unescape(value)
      end
  
      def parse_value(value, operator)
        PARSERS.each do |parser|
          return parser.parse(value) if parser.parseable?(value, operator)
        end
        
        return nil
      end
  
      def hash_with_indifferent_access(params)
        params.is_a?(HashWithIndifferentAccess) ? params : HashWithIndifferentAccess.new(params)
      end
  
      def only_filtering(options)
        options.except(*only_sorting(options).keys).except(:per_page, :page, :action, :controller, :format, :order_by)
      end
  
      def only_sorting(options)
        options.inject({}) do |result, item|
          key, value = item
          result[key] = value if sorting_parameter?(key, value)
          result
        end
      end
  
      def sorting_parameter?(key, value)
        order_by_parameter?(key) or sorting_key_parameter?(key) or sorting_value_parameter?(value)
      end
      
      def order_by_parameter?(key)
        key.to_s == 'order_by'
      end
      
      def sorting_key_parameter?(key)
        key.match(/(.*)\.(#{SORTING_OPERATORS.join('|')})/)
      end
      
      def sorting_value_parameter?(value)
        value.present? && SORTING_OPERATORS.include?(value.to_sym)
      end
  
      def parse_order_by(options)
        sorting_options = []
    
        if order_by = options.delete('order_by')
          if match = order_by.match(/(.*)\.(#{SORTING_OPERATORS.join('|')})/)
            sorting_options << match[1].to_sym.send(match[2])
          else
            sorting_options << order_by.to_sym.asc
          end
        end
    
        sorting_options
      end
  
      def parse_sorting(options)
        options.inject([]) do |result, item|
          key, value = item
      
          attribute = attribute_from(key)
          sorting_operator = sorting_operator_from(key)

          result << attribute.send(sorting_operator || value)        
          result
        end
      end
  
      def sorting_operator_from(key)
        if match = key.match(/.*\.(#{SORTING_OPERATORS.join('|')})/)
          match[1].to_sym
        end
      end
  end
end
