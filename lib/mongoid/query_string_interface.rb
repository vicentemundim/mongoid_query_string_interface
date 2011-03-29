require File.expand_path(File.join('parsers', 'filter_parser'), File.dirname(__FILE__))
require File.expand_path(File.join('parsers', 'filters_parser'), File.dirname(__FILE__))

module Mongoid
  module QueryStringInterface
    NORMAL_CONDITIONAL_OPERATORS = [:exists, :gte, :gt, :lte, :lt, :ne, :size, :near, :within]
    ARRAY_CONDITIONAL_OPERATORS = [:all, :in, :nin]
    CONDITIONAL_OPERATORS = ARRAY_CONDITIONAL_OPERATORS + NORMAL_CONDITIONAL_OPERATORS
    SORTING_OPERATORS = [:asc, :desc]
    OR_OPERATOR = :or

    ATTRIBUTE_REGEX = /^(.*)\.(#{(CONDITIONAL_OPERATORS + SORTING_OPERATORS + [OR_OPERATOR]).join('|')})$/
    OPERATOR_REGEX = /^.*\.(#{Mongoid::QueryStringInterface::CONDITIONAL_OPERATORS.join('|')})$/

    PAGER_ATTRIBUTES = [:total_entries, :total_pages, :per_page, :offset, :previous_page, :current_page, :next_page]

    ORDER_BY_PARAMETER = :order_by
    PAGINATION_PARAMTERS = [:per_page, :page]
    FRAMEWORK_PARAMETERS = [:controller, :action, :format]
    RESERVED_PARAMETERS = FRAMEWORK_PARAMETERS + PAGINATION_PARAMTERS + [ORDER_BY_PARAMETER]
    
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

    def default_filtering_options; {}; end
    def default_sorting_options; []; end
    def default_pagination_options; { :per_page => 12, :page => 1 }; end

    protected
      def pagination_options(options)
        hash_with_indifferent_access(default_pagination_options).merge(options)
      end
  
      def filtering_options(options)
        Mongoid::QueryStringInterface::Parsers::FiltersParser.new(
          only_filtering(options),
          default_filtering_options
        ).parse
      end
  
      def sorting_options(options)
        parse_order_by(options) || default_sorting_options
      end
  
      def hash_with_indifferent_access(params)
        params.is_a?(HashWithIndifferentAccess) ? params : params.with_indifferent_access
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
