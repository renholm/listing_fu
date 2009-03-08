module ListingFuHelper
  def pagination(collection, options = {})
    will_paginate collection, :param_name => "#{collection.settings[:name]}[page]"
  end
  
  def listing(collection, options = {}, &block)
    listing = Listing.new(collection, options)
    
    yield listing
    
    options[:renderer] ||= TableRenderer
    
    concat options[:renderer].new.render(listing), block.binding
  end
  
  def filters(collection, options = {}, &block)
    form_tag('', :method => :get) do
      filter = Filter.new(options)
      
      yield filter

      output = ""
      
      filter.definitions.each do |definition|
        tag = "#{collection.settings[:name]}[filters][#{definition[:method]}]"
        
        output += label_tag tag, definition[:name]
        
        case definition[:type]
        when :text 
          output += text_field_tag tag, collection.settings[:filters][definition[:method]]
        when :option
          output += select_tag tag, options_for_select(([""] + definition[:choices]).collect{|c| [c.to_s, c.to_s]}, collection.settings[:filters][definition[:method].to_s])
        end
      end

      output += submit_tag 'Filter', :disable_with => 'Filtering..'
      
      output
    end
  end
  
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
  
  class Listing
    attr_accessor :collection, :options, :rows
    
    def initialize(collection, options)
      self.collection = collection
      self.options = options
      self.rows = []
    end
    
    def column(column, options = {}, &block)
      
    end
    
    def actions(options = {}, &block)
      
    end
  end
  
  class TableRenderer
    def render(listing)
      # TODO: The magic table renderer
    end
  end
  
end