module ListingFu
  module Helper
    class TableRenderer < Renderer
      def render
        concat "<table#{table_options}>"
  
        concat "<tr>"
        definitions.each do |definition|
          concat "<th>"
  
          if definition[:type] == :own_column || definition[:type] == :erb_column 
            name = @collection.settings[:name]
  
            label = definition[:options][:label] || definition[:column].to_s.humanize
  
            if definition[:filterable]
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
              
              concat "<a href=\"#{template.url_for(url_hash)}\">#{label}</a>"
            else
              concat label
            end
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
end