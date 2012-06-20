require "query_string_interface"
require "mongoid/paginate"

module Mongoid
  module QueryStringInterface
    include ::QueryStringInterface
    include ::QueryStringInterface::Helpers

    def self.extended(base)
      base.extend Mongoid::Paginate unless base.methods.include?(:paginate)
    end

    PAGER_ATTRIBUTES = [:total_entries, :total_pages, :per_page, :offset, :previous_page, :current_page, :next_page]

    def filter_by(params={})
      params = hash_with_indifferent_access(params)
      filter_only_and_order_by(params).paginate(pagination_options(params))
    end

    def filter_with_pagination_by(params)
      build_results_with_pager_for(filter_by(params))
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
      params = hash_with_indifferent_access(params)
      where(filtering_options(params)).filter_fields_by(params)
    end

    def paginated_collection_with_filter_by(params={})
      params = hash_with_indifferent_access(params)

      pagination = pagination_options(params)
      collection = WillPaginate::Collection.new pagination[:page], pagination[:per_page], where(filtering_options(params)).count

      build_pager_from(collection)
    end

    def filter_fields_by(params)
      params = field_filtering_options(hash_with_indifferent_access(params))
      params.present? ? send(*params.first) : criteria
    end

    def field_filtering_options(params)
      hash = super
      if hash.present?
        hash = hash.dup
        hash[:without] = hash.delete(:except)
      end
      hash
    end

    protected
      def sorting_options(options)
        super(options).map do |sort_option|
          attribute = sort_option.keys.first
          attribute.send(sort_option[attribute])
        end
      end

      def results_with_pager(collection, total, params={})
        params = hash_with_indifferent_access(params)
        pagination = pagination_options(params)

        result = create_paginatable_collection(collection, total, pagination[:page], pagination[:per_page])
        build_results_with_pager_for(result)
      end

      def build_pager_from(collection)
        PAGER_ATTRIBUTES.inject({}) do |result, attr|
          result[attr] = collection.send(attr)
          result
        end
      end

      def build_results_with_pager_for(collection)
        { :pager => build_pager_from(collection), collection_name_in_pagination_result => collection }
      end

      def collection_name_in_pagination_result
        model_name.human.underscore.pluralize.to_sym
      end
  end
end
