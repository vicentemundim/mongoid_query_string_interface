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
            parse_item(item)
          end
        end
        
        private
          def parse_item(item)
            other_parsers.each do |parser|
              return parser.parse(item) if parser.parseable?(item, '')
            end
          end

          def other_parsers
            @other_parsers ||= Mongoid::QueryStringInterface::Parsers::FilterParser::PARSERS.reject do |parser|
              parser.is_a?(ArrayParser)
            end
          end

          def conditional_operators
            @conditional_operators ||= Mongoid::QueryStringInterface::ARRAY_CONDITIONAL_OPERATORS.map { |o| "$#{o}" }
          end
      end
    end
  end
end