module ListingFu
  module Helper
    class Renderer
      attr_accessor :collection, :options, :template, :definitions
    
      def initialize(collection, options, template)
        self.collection = collection
        self.options = options
        self.template = template
        self.definitions = []
      end
    
      def column(column, options = {}, &block)
        hash = {
          :filterable => collection.settings[:available_filters].include?(column.to_sym),
          :column => column, 
          :options => options
        }
        
        if block_given?
          definitions << {:type => :erb_column, :block => block}.merge(hash)
        else
          definitions << {:type => :own_column, :block => Proc.new {|item| item.send(column)}}.merge(hash)
        end
    
        nil
      end
    
      def actions(options = {}, &block)
        definitions << {:type => :erb_actions, :block => block, :options => options}
    
        nil
      end
    end
  end
end