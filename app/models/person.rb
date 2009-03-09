class Person < ActiveRecord::Base
  has_many :memberships
  has_many :groups, :through => :memberships

  has_one :account

  def self.listing_filter(filters)
    fields = {}
    
    filters.each do |name, definition|
      method_declaration = lambda do
        if definition.is_a? Proc
          self.instance_eval &definition
        elsif definition.is_a? Symbol or definition.is_a? String
          self.send(definition).to_s
        else
          raise 'Error: Filter needs to be either a Symbol, String or a Proc'
        end
      end
      
      define_method "_#{name.to_s}", &method_declaration
      define_method "_#{name.to_s}_sort", &method_declaration

      fields["_#{name.to_s}"] = {}
      fields["_#{name.to_s}_sort"] = {:index => :untokenized}
    end
    
    acts_as_ferret :fields => fields
  end
  
  # TODO: merge this and the proxylisting in a module?
  def self.listing(params, options = {}, ferret_options = {})
    # the default name for a listing is listing
    options[:name] ||= :listing
    
    listing_hash = params[options[:name]] || {}
    
    if listing_hash[:sort]
      field = "_#{listing_hash[:sort][:column]}_sort".to_sym
      reverse = listing_hash[:sort][:reverse] == "true"
      
      ferret_options[:sort] = [Ferret::Search::SortField.new(field, :reverse => reverse)]
    end
    
    query = listing_hash[:query] || ""

    if filters = listing_hash[:filters]
      filters.each do |filter, filter_query|
        query += "_#{filter}:#{filter_query} " unless filter_query.blank?
      end
    end

    query = "*" if query == ""
    
    ferret_options[:page] = listing_hash[:page] || 1
    ferret_options[:per_page] = options[:per_page] || 15

    search_results = self.find_with_ferret(query, ferret_options)
    
    # save the settings inside the SearchResults object so we can use them inside our view later on
    search_results.settings[:name] = options[:name]
    search_results.settings[:filters] = listing_hash[:filters] || {}
    search_results.settings[:sort] = listing_hash[:sort] || {}
    
    search_results
  end
  
  listing_filter :name => :name, :age => :age
  # listing_filter :name => :name, :age => :age, :account_name => lambda { account.name }, :groups => lambda { groups.join(' ') }
end
