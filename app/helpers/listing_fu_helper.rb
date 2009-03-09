module ListingFuHelper
  def pagination(collection, options = {})
    will_paginate collection, :param_name => "#{collection.settings[:name]}[page]"
  end
  
  def listing(collection, options = {}, &block)
    options[:renderer] ||= TableRenderer

    renderer = options[:renderer].new(collection, options, self)
    
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
  
  class TableRenderer < Renderer
    
    def render
      concat "<table#{table_options}>"
      
      concat "<tr>"
      definitions.each do |definition|
        concat "<th>"

        if definition[:type] == :own_column || definition[:type] == :erb_column 
          name = @collection.settings[:name]

          label = definition[:options][:label] || definition[:column].to_s.humanize

          sort_column = definition[:column]

          # if the sorting column is the current column of the current definition,
          # check if we should swtich the order of the sorting
          sort_reverse = if @collection.settings[:sort][:column] == sort_column.to_s
              if @collection.settings[:sort][:reverse] == "true"
                "false"
              else
                "true"
              end  
            else
              "false"
            end

          url_hash = { name => 
            {:sort => {:column => sort_column, :reverse => sort_reverse}, 
             :filters => @collection.settings[:filters]}
            }

          concat "<a href=\"#{template.url_for(url_hash)}\">#{label }</a>"
        end
        
        concat "</th>"
      end
      concat "</tr>"
      
      collection.each do |item|
        concat "<tr#{tr_options(item)}>"
        
        definitions.each do |definition|
          case definition[:type]
          when :own_column
            concat "<td#{td_options(definition[:options])}>" + definition[:block].call(item).to_s + "</td>"
          when :erb_column
            concat "<td#{td_options(definition[:options])}>"
            
            definition[:block].call(item)
            
            concat "</td>"
          when :erb_actions
            definition[:block].call(item)
          end
        end
        
        concat "</tr>"
      end

      concat "</table>"
    end
    
    private
    def concat(string)
      template.concat string
    end
    
    def table_options
      options[:html_options] ||= {}
      
      output = to_html_attributes options[:html_options]

      " #{output}" unless output.blank?
    end
    
    def tr_options(item)
      output = ""
      
      if colorize = options[:colorize]
        if colorize.is_a? String
          output = to_html_attributes({:class => colorize})
        elsif colorize.is_a? Proc
          output = to_html_attributes({:class => colorize.call(item)})
        elsif colorize == :none
          output = ""
        end
      else
        output = to_html_attributes({:class => template.cycle('even', 'odd')})
      end

      " #{output}"
    end

    def td_options(td_options)
      td_options[:html_options] ||= {}
      
      output = to_html_attributes td_options[:html_options]

      " #{output}" unless output.blank?
    end
    
    def to_html_attributes(array)
      array.collect{|k, v| "#{k}=\"#{v}\""}.join(' ')
    end
  end
  
  
end