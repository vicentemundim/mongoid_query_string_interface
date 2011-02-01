module Mongoid
  module QueryStringInterface
    module Parsers
      class ArrayParser
        ARRAY_SEPARATOR = '|'
        ARRAY_CONDITIONAL_OPERATORS = [:$all, :$in, :$nin]
  
        def parseable?(value, operator)
          operator && ARRAY_CONDITIONAL_OPERATORS.include?(operator.to_sym)
        end
  
        def parse(value)
          value.split(ARRAY_SEPARATOR).map(&:strip).map do |item|
            regex_parser.parse(item) or item
          end
        end
        
        private
          def regex_parser
            @regex_parser ||= RegexParser.new
          end
      end
    end
  end
end