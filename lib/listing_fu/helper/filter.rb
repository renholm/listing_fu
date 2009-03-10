module ListingFu
  module Helper
    class Filter
      attr_accessor :definitions
    
      def initialize(options)
        self.definitions = []
      end
    
      def text_filter(method, options = {})
        options[:name] ||= method.to_s.humanize
    
        self.definitions << {:type => :text, :method => method, :name => options[:name]}
      end
    
      def options_filter(method, choices, options = {})
        options[:name] ||= method.to_s.humanize
    
        self.definitions << {:type => :option, :choices => choices, :method => method, :name => options[:name]}
      end
    end
  end
end