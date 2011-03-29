require File.expand_path(File.join('parsers', 'date_time_parser'), File.dirname(__FILE__))
require File.expand_path(File.join('parsers', 'number_parser'), File.dirname(__FILE__))
require File.expand_path(File.join('parsers', 'array_parser'), File.dirname(__FILE__))
require File.expand_path(File.join('parsers', 'regex_parser'), File.dirname(__FILE__))
require File.expand_path(File.join('parsers', 'boolean_and_nil_parser'), File.dirname(__FILE__))

module Mongoid
  module QueryStringInterface
    CONDITIONAL_OPERATORS = [:all, :exists, :gte, :gt, :in, :lte, :lt, :ne, :nin, :size, :near, :within]
    SORTING_OPERATORS = [:asc, :desc]
    OR_OPERATOR = :or

    ATTRIBUTE_REGEX = /(.*)\.(#{(CONDITIONAL_OPERATORS + SORTING_OPERATORS + [OR_OPERATOR]).join('|')})/
    PAGER_ATTRIBUTES = [:total_entries, :total_pages, :per_page, :offset, :previous_page, :current_page, :next_page]

    ORDER_BY_PARAMETER = :order_by
    PAGINATION_PARAMTERS = [:per_page, :page]
    FRAMEWORK_PARAMETERS = [:controller, :action, :format]
    RESERVED_PARAMETERS = FRAMEWORK_PARAMETERS + PAGINATION_PARAMTERS + [ORDER_BY_PARAMETER]

    PARSERS = [
      Mongoid::QueryStringInterface::Parsers::DateTimeParser.new,
      Mongoid::QueryStringInterface::Parsers::NumberParser.new,
      Mongoid::QueryStringInterface::Parsers::ArrayParser.new,
      Mongoid::QueryStringInterface::Parsers::RegexParser.new,
      Mongoid::QueryStringInterface::Parsers::BooleanAndNilParser.new
    ]
    
    def filter_by(params={})
      params = hash_with_indifferent_access(params)
      filter_only_and_order_by(params).paginate(pagination_options(params))
    end

    def filter_with_pagination_by(params)
      result = filter_by(params)

      pager = PAGER_ATTRIBUTES.inject({}) do |pager, attr|
        pager[attr] = result.send(attr)
        pager
      end

      return { :pager => pager, model_name.human.underscore.pluralize.to_sym => result }
    end

    def filter_with_optimized_pagination_by(params={})
      params = hash_with_indifferent_access(params)
      per_page = (params[:per_page] || default_pagination_options[:per_page]).to_i
      page = (params[:page] || default_pagination_options[:page]).to_i
      skip = per_page * (page - 1)

      filter_only_and_order_by(params).skip(skip).limit(per_page)
    end

    def filter_only_and_order_by(params={})
      params = hash_with_indifferent_access(params)
      filter_only_by(params).order_by(*sorting_options(params))
    end

    def filter_only_by(params={})
      where(filtering_options(hash_with_indifferent_access(params)))
    end

    def paginated_collection_with_filter_by(params={})
      params = hash_with_indifferent_access(params)
  
      pagination = pagination_options(params)
      pager = WillPaginate::Collection.new pagination[:page], pagination[:per_page], where(filtering_options(params)).count
  
      PAGER_ATTRIBUTES.inject({}) do |result, attr|
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

    def default_pagination_options
      { :per_page => 12, :page => 1 }
    end

    protected
      def pagination_options(options)
        hash_with_indifferent_access(default_pagination_options).merge(options)
      end
  
      def filtering_options(options)
        hash_with_indifferent_access(default_filtering_options).merge(parse_operators(only_filtering(options)))
      end
  
      def sorting_options(options)
        parse_order_by(options) || default_sorting_options
      end
  
      def parse_operators(options)
        options.inject({}) do |result, item|
          key, value = item
      
          attribute = attribute_from(key)
          
          if or_attribute?(attribute)
            parse_or_attribute(attribute, key, value, result)
          else
            parse_normal_attribute(attribute, key, value, result)
          end
        end
      end
      
      def parse_or_attribute(attribute, key, value, result)
        result["$or"] = ::JSON.parse(unescape(value)).map do |filters|
          parse_operators(filters)
        end
        
        result
      end
      
      def parse_normal_attribute(attribute, key, value, result)
        operator = operator_from(key)
        value = parse_value(value, operator)

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
  
      def attribute_from(key)
        if key =~ ATTRIBUTE_REGEX
          $1.to_sym
        else
          key.to_sym
        end
      end
      
      def or_attribute?(attribute)
        OR_OPERATOR == attribute
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
        if value.is_a?(String)
          value = unescape(value)
          
          PARSERS.each do |parser|
            return parser.parse(value) if parser.parseable?(value, operator)
          end
        
          return nil
        else
          value
        end
      end
  
      def hash_with_indifferent_access(params)
        params.is_a?(HashWithIndifferentAccess) ? params : HashWithIndifferentAccess.new(params)
      end
  
      def only_filtering(options)
        options.except(*RESERVED_PARAMETERS)
      end
  
      def parse_order_by(options)
        if options.has_key?('order_by')
          options['order_by'].split('|').map do |field|
            sorting_operator_for(field)
          end
        end
      end

      def sorting_operator_for(field)
        if match = field.match(/(.*)\.(#{SORTING_OPERATORS.join('|')})/)
          match[1].to_sym.send(match[2])
        else
          field.to_sym.asc
        end
      end
  end
end
