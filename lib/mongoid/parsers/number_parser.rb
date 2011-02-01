module Mongoid
  module QueryStringInterface
    module Parsers
      class NumberParser
        def parseable?(value, operator)
          integer?(value) or float?(value)
        end
        
        def parse(value)
          if integer?(value)
            value.to_i
          elsif float?(value)
            value.to_f
          end
        end
        
        private
          def integer?(value)
            value =~ /^\d+$/
          end
          
          def float?(value)
            value =~ /^(\d+)(\.?\d*)$/
          end
      end
    end
  end
end