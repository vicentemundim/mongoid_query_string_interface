module Mongoid
  module QueryStringInterface
    module Parsers
      class NumberParser
        def self.parseable?(value)
          not parse(value).nil?
        end
        
        def self.parse(value)
          if value =~ /^\d+$/
            value.to_i
          elsif value =~ /^(\d+)(\.?\d*)$/
            value.to_f
          end
        end
      end
    end
  end
end