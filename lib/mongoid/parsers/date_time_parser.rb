module Mongoid
  module QueryStringInterface
    module Parsers
      class DateTimeParser
        def parseable?(value)
          not parse(value).nil?
        end
        
        def parse(value)
          value.to_time and Time.parse(value)
        rescue Exception
          nil
        end
      end
    end
  end
end