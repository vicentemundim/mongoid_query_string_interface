module Mongoid
  module QueryStringInterface
    CONDITIONAL_OPERATORS = [:all, :exists, :gte, :gt, :in, :lte, :lt, :ne, :nin, :size, :near, :within]
    ARRAY_CONDITIONAL_OPERATORS = [:all, :in, :nin]
    SORTING_OPERATORS = [:asc, :desc]

    def filter_by(params={})
      params = hash_with_indifferent_access(params)
      where(filtering_options(params)).order_by(*sorting_options(params)).paginate(pagination_options(params))
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
  
      def parse_value(value, operator)
        parse_date(value) or parse_integer(value) or parse_array(value, operator) or value
      end
  
      def parse_date(date)
        date.to_time and Time.parse(date)
      rescue Exception
        nil
      end
  
      def parse_integer(integer)
        if match = integer.match(/\d+/)
          match[0].to_i
        end
      end
  
      def parse_float(float)
        if match = float.match(/^(\d+)(\.?\d*)$/)
          match[0].to_f
        end
      end
  
      def parse_array(value, operator)
        split_and_strip(value) if array_operator?(operator)
      end
  
      def array_operator?(operator)
        ARRAY_CONDITIONAL_OPERATORS.map { |op| "$#{op}" }.include?(operator.to_s)
      end
  
      def split_and_strip(values)
        values.split('|').map(&:strip)
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
        key.to_s == 'order_by' or key.match(/(.*)\.(#{SORTING_OPERATORS.join('|')})/) or SORTING_OPERATORS.include?(value.to_sym) 
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
