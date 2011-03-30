require 'cgi'

require File.expand_path(File.join('date_time_parser'), File.dirname(__FILE__))
require File.expand_path(File.join('number_parser'), File.dirname(__FILE__))
require File.expand_path(File.join('array_parser'), File.dirname(__FILE__))
require File.expand_path(File.join('regex_parser'), File.dirname(__FILE__))
require File.expand_path(File.join('boolean_and_nil_parser'), File.dirname(__FILE__))

module Mongoid
  module QueryStringInterface
    module Parsers
      class FilterParser
        attr_reader :raw_attribute, :raw_value

        PARSERS = [
          Mongoid::QueryStringInterface::Parsers::DateTimeParser.new,
          Mongoid::QueryStringInterface::Parsers::NumberParser.new,
          Mongoid::QueryStringInterface::Parsers::ArrayParser.new,
          Mongoid::QueryStringInterface::Parsers::RegexParser.new,
          Mongoid::QueryStringInterface::Parsers::BooleanAndNilParser.new
        ]

        def initialize(raw_attribute, raw_value)
          @raw_attribute = raw_attribute
          @raw_value = raw_value
        end

        def attribute
          @attribute ||= parsed_attribute
        end

        def value
          @value ||= expanded_value
        end

        def operator
          @operator ||= operator_from(raw_attribute)
        end

        def or_attribute?
          raw_attribute == 'or'
        end

        def include?(other_filter)
          if or_attribute?
            json_value.any? do |filters|
              filters.filter_parsers.any? do |filter_parser|
                filter_parser.attribute == other_filter.attribute &&
                  conditional_array_operators.include?(filter_parser.operator) &&
                  filter_parser.operator == other_filter.operator
              end
            end
          end
        end

        def merge(other_filter)
          if or_attribute?
            @value = json_value.map do |filters|
              filters.filter_parsers << other_filter
              filters.parse
            end
          elsif conditional_array_operators.include?(other_filter.operator) && operator == other_filter.operator
            @value = value.inject({}) do |result, filter|
              filter_operation, filter_value = filter
              filter_value = filter_value.concat(other_filter.value[filter_operation]) if other_filter.value[filter_operation]
              result[filter_operation] = filter_value
              result
            end
          else
            @value = value.merge(other_filter.value)
          end
        end

        private
          def parsed_attribute
            if or_attribute?
              '$or'
            elsif raw_attribute =~ Mongoid::QueryStringInterface::ATTRIBUTE_REGEX
              $1
            else
              raw_attribute
            end
          end

          def expanded_value
            if operator
              if or_attribute?
                parsed_json_value
              else
                { operator => parsed_value }
              end
            else
              parsed_value
            end
          end

          def parsed_value
            if raw_value.is_a?(String)
              PARSERS.each do |parser|
                return parser.parse(unescaped_raw_value) if parser.parseable?(unescaped_raw_value, operator)
              end

              return nil
            else
              raw_value
            end
          end

          def parsed_json_value
            if unescaped_raw_value.is_a?(String)
              json_value.map(&:parse)
            else
              unescaped_raw_value
            end
          end

          def json_value
            raw_or_data = ::JSON.parse(unescaped_raw_value)

            raise "$or query filters must be given as an array of hashes" unless valid_or_filters?(raw_or_data)

            raw_or_data.map do |filters|
              FiltersParser.new(filters)
            end
          end

          def valid_or_filters?(raw_or_data)
            raw_or_data.is_a?(Array) and raw_or_data.all? { |item| item.is_a?(Hash) }
          end

          def unescaped_raw_value
            @unescaped_raw_value ||= raw_value.is_a?(String) ? CGI.unescape(raw_value) : raw_value
          end

          def conditional_array_operators
            Mongoid::QueryStringInterface::ARRAY_CONDITIONAL_OPERATORS.map { |o| "$#{o}" }
          end

          def operator_from(attribute)
            if or_attribute?
              '$or'
            elsif attribute =~ Mongoid::QueryStringInterface::OPERATOR_REGEX
              "$#{$1}"
            end
          end
      end
    end
  end
end