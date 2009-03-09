module ListingFuHelper
  def pagination(collection, options = {})
    will_paginate collection, :param_name => "#{collection.settings[:name]}[page]"
  end
  
  def listing(collection, options = {}, &block)
    options[:renderer] ||= TableRenderer

    renderer = options[:renderer].new(collection, options, self, &block)
    
    yield renderer
    
    renderer.render
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
  
  class Renderer
    attr_accessor :definitions, :collection, :options, :template, :proc
    
    def initialize(collection, options, template, &proc)
      self.collection = collection
      self.options = options
      self.template = template
      self.proc = proc

      self.definitions = []
      
    end
    
    def column(column, options = {}, &block)
      if block_given?
        puts "** adding definition to definitions"
        
        self.definitions << {:type => :erb, :block => block}
      else
        puts "** creating new definition"
        
        self.definitions << {:type => :own, :block => Proc.new {|item| item.send(:name)}}
      end
      
      nil
    end
    
    def actions(options = {}, &block)
      # TODO: take care of this..
    end
  end
  
  class TableRenderer < Renderer
    def render
      output = ""

      self.collection.each do |item|
        self.definitions.each do |definition|
          case definition[:type]
          when :own
            self.template.concat "<b>" + definition[:block].call(item) + "</b>"
          when :erb
            self.template.concat "<b>"
            
            definition[:block].call(item)
            
            self.template.concat "</b>"
          end

        end
      end
    end
  end
  
end