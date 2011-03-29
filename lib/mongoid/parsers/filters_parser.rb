module Mongoid
  module QueryStringInterface
    module Parsers
      class FiltersParser
        attr_reader :filters, :default_filters

        def initialize(filters, default_filters={})
          @filters = filters.with_indifferent_access
          @default_filters = default_filters.with_indifferent_access
        end

        def parse
          default_filters.merge(parsed_filters)
        end

        private

          def parsed_filters
            filter_parsers.inject({}) do |result, filter_parser|
              if result.has_key?(filter_parser.attribute)
                result[filter_parser.attribute].merge!(filter_parser.value)
              else
                result[filter_parser.attribute] = filter_parser.value
              end

              result
            end
          end

          def filter_parsers
            filters.map do |raw_attribute, raw_value|
              FilterParser.new(raw_attribute, raw_value)
            end
          end
      end
    end
  end
end