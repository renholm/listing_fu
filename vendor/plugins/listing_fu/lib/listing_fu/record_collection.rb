module ListingFu
  class RecordCollection
    attr_accessor :filter_settings, :ferret_search_results 
    
    def initialize()
      self.filter_settings = {}
    end

    [:per_page, :current_page, :total_hits, :total_pages].each do |method|
      define_method method do
        ferret_search_results.send(method)
      end
    end
  end
end
