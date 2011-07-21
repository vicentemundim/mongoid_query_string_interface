require File.expand_path(File.join('helpers'), File.dirname(__FILE__))
require File.expand_path(File.join('paginate'), File.dirname(__FILE__))
require File.expand_path(File.join('parsers', 'filter_parser'), File.dirname(__FILE__))
require File.expand_path(File.join('parsers', 'filters_parser'), File.dirname(__FILE__))

module Mongoid
  module QueryStringInterface
    include Mongoid::QueryStringInterface::Helpers
    include Mongoid::Paginate unless instance_methods(:false).include?(:paginate)

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
    CONTROL_PARAMETERS = [:disable_default_filters]
    RESERVED_PARAMETERS = FRAMEWORK_PARAMETERS + PAGINATION_PARAMTERS + [ORDER_BY_PARAMETER] + CONTROL_PARAMETERS

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
    def sorting_attributes_to_replace; {} end
    def filtering_attributes_to_replace; {} end

    protected
      def pagination_options(options)
        hash_with_indifferent_access(default_pagination_options).merge(options)
      end

      def filtering_options(options)
        Mongoid::QueryStringInterface::Parsers::FiltersParser.new(
          only_filtering(options),
          options.has_key?(:disable_default_filters) ? {} : default_filtering_options,
          filtering_attributes_to_replace
        ).parse
      end

      def sorting_options(options)
        parse_order_by(options) || default_sorting_options.map { |field| sorting_operator_for(field) }
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
        if field.is_a?(Mongoid::Criterion::Complex)
          replace_attribute(field.key, sorting_attributes_to_replace).to_sym.send(field.operator)
        elsif match = field.match(/(.*)\.(#{SORTING_OPERATORS.join('|')})/)
          replace_attribute(match[1], sorting_attributes_to_replace).to_sym.send(match[2])
        else
          replace_attribute(field, sorting_attributes_to_replace).to_sym.asc
        end
      end
  end
end
