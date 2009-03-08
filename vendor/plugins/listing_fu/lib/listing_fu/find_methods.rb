module ListingFu
  module FindMethods
    def self.included(base)
      base.class_eval { include InstanceMethods }
    end
    
    module InstanceMethods
      def listing(params, options = {})
        self.find_by_contents
      end
    end
  end
end