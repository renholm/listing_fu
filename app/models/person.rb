class Person < ActiveRecord::Base
  has_many :memberships
  has_many :groups, :through => :memberships

  has_one :account

  def self.listing_filter(filters)
    filters.each do |name, definition|
      puts "** defining method _#{name.to_s}"
  
      define_method "_#{name.to_s}" do
        if definition.is_a? Proc
          # TODO: handle nil values, maby with a begin rescue? or break the proc apart
          self.instance_eval &definition
        elsif definition.is_a? Symbol or definition.is_a? String
          self.send(definition).to_s
        else
          raise 'Error: Filter needs to be either a Symbol, String or a Proc'
        end
      end
    end
    
    # TODO: maybe define all attributes as filters as well, so we can sort on them!
    acts_as_ferret :fields => filters.keys.collect{|f| "_#{f.to_s}"}
  end
  
  # TODO: merge this and the proxylisting in a module?
  def self.listing(params, options = {}, ferret_options = {})
    # the default name for a listing is listing
    options[:name] ||= :listing
    
    listing_hash = params[options[:name]] || {}
    
    if listing_hash[:sort]
      field = "_#{listing_hash[:sort][:field]}".to_sym
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
    
    ferret_options[:per_page] = listing_hash[:per_page] || 15

    search_results = self.find_with_ferret(query, ferret_options)
    
    # save the settings inside the SearchResults object so we can use them inside our view later on
    search_results.settings[:name] = options[:name]
    search_results.settings[:filters] = listing_hash[:filters] || {}
    search_results.settings[:sort] = listing_hash[:sort] || {}
    
    search_results
  end
  
  listing_filter :name => :name, :age => :age, :account_name => lambda { account.name }, :groups => lambda { groups.join(' ') }
end
