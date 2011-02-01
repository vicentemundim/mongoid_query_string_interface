module Mongoid
  module QueryStringInterface
    module Parsers
      class RegexParser
        def parseable?(value, operator)
          value =~ /^\/(.*)\/(i|m|x)?$/
        end
        
        def parse(value)
          if value =~ /^\/(.*)\/(i|m|x)?$/
            eval($&)
          end
        end
      end
    end
  end
end