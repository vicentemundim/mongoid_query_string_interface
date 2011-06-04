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
    end
  end
end
