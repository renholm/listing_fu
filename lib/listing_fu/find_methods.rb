module ListingFu
  module FindMethods
    def self.included(base)
      base.extend(InstanceMethods)
      base.class_eval { include InstanceMethods }
    end
    
    module InstanceMethods
      def listing(params, options = {}, find_options = {})
        ferret_options = {}
        
        # the default name for a listing is listing
        options[:name] ||= :listing

        listing_hash = params[options[:name]] || {}

        if listing_hash[:sort]
          column = "_#{listing_hash[:sort][:column]}_sort".to_sym
          reverse = listing_hash[:sort][:reverse] == "true"
          
          ferret_options[:sort] = [Ferret::Search::SortField.new(column, :reverse => reverse, :type => :string)]
        end

        query = listing_hash[:query] || ""

        if filters = listing_hash[:filters]
          filters.each do |filter, filter_query|
            query += "_#{filter}:#{filter_query.downcase} " unless filter_query.blank?
          end
        end

        query = "*" if query == ""

        ferret_options[:page] = listing_hash[:page] || 1
        ferret_options[:per_page] = options[:per_page] || 15

        search_results = self.find_with_ferret(query, ferret_options, find_options)

        # save the settings inside the SearchResults object so we can use them inside our view later on
        search_results.settings[:name] = options[:name]
        search_results.settings[:filters] = listing_hash[:filters] || {}
        search_results.settings[:sort] = listing_hash[:sort] || {}
        search_results.settings[:available_filters] = self._available_filters

        search_results
      end
    end
  end
end