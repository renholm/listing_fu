module ListingFuHelper
  def listing(collection, options = {}, &block)
    yield Listing.new(collection, options)
  end
  
  def listing_filter(options = {})
    
  end
  
  
  class Listing
    attr_accessor :collection, :options
    
    def initialize(collection, options)
      self.collection = collection
      self.options = options
    end
    
    def column(column, options = {})
      
    end
  end
end