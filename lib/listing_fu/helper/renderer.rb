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
        if block_given?
          definitions << {:type => :erb_column, :block => block, :column => column, :options => options}
        else
          definitions << {:type => :own_column, :block => Proc.new {|item| item.send(column)}, :column => column, :options => options}
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