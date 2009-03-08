module ListingFu
  class ResultsContainer
    attr_accessor :settings, :search_results 
    
    def initialize()
      self.settings = {}
    end

    [:per_page, :current_page, :total_hits, :total_pages].each do |method|
      define_method method do
        search_results.send(method)
      end
    end
  end
end
