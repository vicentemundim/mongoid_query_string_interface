module Mongoid
  module QueryStringInterface
    module Parsers
      class DateTimeParser
        DATE_REGEX = /^(?:\d{4}-\d{2}-\d{2}|\d{4}-\d{1,2}-\d{1,2}[T \t]+\d{1,2}:\d{2}:\d{2}(\.[0-9]*)?([ \t]*)(Z?|[-+]\d{2}?(:?\d{2})?))$/

        def parseable?(value, operator)
          DATE_REGEX.match(value)
        end
        
        def parse(value)
          Time.parse(value)
        end
      end
    end
  end
end