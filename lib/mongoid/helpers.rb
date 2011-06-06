module Mongoid
  module QueryStringInterface
    module Helpers
      def hash_with_indifferent_access(params)
        params.is_a?(HashWithIndifferentAccess) ? params : params.with_indifferent_access
      end

      def replace_attribute(attribute, hash_with_attributes_to_replace)
        hash = hash_with_indifferent_access(hash_with_attributes_to_replace)
        hash.has_key?(attribute) ? hash[attribute] : attribute
      end

      def replaced_attribute_name(attribute, hash_with_attributes_to_replace)
        attribute = replace_attribute(attribute, hash_with_attributes_to_replace)
        attribute.is_a?(Hash) ? attribute[:to] : attribute
      end

      def replaced_attribute_value(attribute, value, hash_with_attributes_to_replace, raw_params)
        attribute = replace_attribute(attribute, hash_with_attributes_to_replace)
        attribute.is_a?(Hash) ? attribute[:convert_value_to].call(value, raw_params) : value
      end
    end
  end
end
