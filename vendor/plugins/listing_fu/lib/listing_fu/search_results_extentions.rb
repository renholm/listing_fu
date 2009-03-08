module ListingFu
  module SearchResultsExtentions
    def self.included(base)
      base.class_eval { include InstanceMethods }
    end
    
    module InstanceMethods
      def settings
        @listing_fu_settings = {} unless @listing_fu_settings

        @listing_fu_settings
      end
    end
  end
end