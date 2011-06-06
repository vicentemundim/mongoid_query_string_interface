module Mongoid
  module QueryStringInterface
    module Parsers
      class FiltersParser
        include Mongoid::QueryStringInterface::Helpers

        attr_reader :filters, :default_filters

        def initialize(filters, default_filters={}, attributes_to_replace={}, raw_filters=nil)
          @filters = filters.with_indifferent_access
          @default_filters = default_filters.with_indifferent_access
          @attributes_to_replace = attributes_to_replace.with_indifferent_access
          @raw_filters = raw_filters.nil? ? @filters : raw_filters.with_indifferent_access
        end

        def parse
          result = default_filters.inject({}) do |result, item|
            raw_attribute, raw_value = item
            result[replaced_attribute_name(raw_attribute, @attributes_to_replace).to_s] = replaced_attribute_value(raw_attribute, raw_value, @attributes_to_replace, @raw_filters)
            result
          end
          result.merge(parsed_filters)
        end

        def filter_parsers
          @filter_parsers ||= filters.map do |raw_attribute, raw_value|
            FilterParser.new(raw_attribute, raw_value, @attributes_to_replace, @raw_filters)
          end
        end

        private

          def parsed_filters
            filter_parsers_hash.inject({}) do |result, item|
              attribute, filter_parser = item

              result[attribute] = filter_parser.value

              result
            end
          end

          def filter_parsers_hash
            optimized_filter_parsers.inject({}) do |result, filter_parser|
              if result.has_key?(filter_parser.attribute)
                result[filter_parser.attribute].merge(filter_parser)
              else
                result[filter_parser.attribute] = filter_parser
              end

              result
            end
          end

          def optimized_filter_parsers
            if or_filter_parser
              filter_parsers.inject([]) do |result, filter_parser|
                if filter_parser != or_filter_parser && or_filter_parser.include?(filter_parser)
                  or_filter_parser.merge(filter_parser)
                else
                  result << filter_parser
                end

                result
              end
            else
              filter_parsers
            end
          end

          def or_filter_parser
            @or_filter_parser ||= filter_parsers.select { |filter_parser| filter_parser.or_attribute? }.first
          end
      end
    end
  end
end
