module Mongoid
  module QueryStringInterface
    module Parsers
      class DateTimeParser
        def self.parseable?(value)
          not self.parse(value).nil?
        end
        
        def self.parse(value)
          value.to_time and Time.parse(value)
        rescue Exception
          nil
        end
      end
    end
  end
end