module Mongoid
  module QueryStringInterface
    module Parsers
      class BooleanAndNilParser
        def parseable?(value, operator)
          !value.nil? && !value.empty?
        end
        
        def parse(value)
          if boolean?(value)
            value.strip == 'true'
          elsif value.nil? or value.empty? or nil_value?(value)
            nil
          else
            value
          end
        end
        
        private
          def boolean?(value)
            value && ['true', 'false'].include?(value.strip)
          end
          
          def nil_value?(value)
            value && ['nil', 'null'].include?(value.strip)
          end
      end
    end
  end
end