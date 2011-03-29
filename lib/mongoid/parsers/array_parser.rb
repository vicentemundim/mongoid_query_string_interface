module Mongoid
  module QueryStringInterface
    module Parsers
      class ArrayParser
        ARRAY_SEPARATOR = '|'
  
        def parseable?(value, operator)
          operator && conditional_operators.include?(operator)
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

          def conditional_operators
            @conditional_operators ||= Mongoid::QueryStringInterface::ARRAY_CONDITIONAL_OPERATORS.map { |o| "$#{o}" }
          end
      end
    end
  end
end