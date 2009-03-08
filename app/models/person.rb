class Person < ActiveRecord::Base
  has_many :memberships
  has_many :groups, :through => :memberships

  has_one :account

  def self.listing_filter(filters)
    filters.each do |name, definition|
      puts "** defining method _#{name.to_s}"
  
      define_method "_#{name.to_s}" do
        if definition.is_a? Proc
          self.instance_eval &definition
        elsif definition.is_a? Symbol or definition.is_a? String
          self.send(definition)
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
    options[:name] ||= :listing
    
    listing_hash = params[options[:name]]
    
    results_container = ListingFu::ResultsContainer.new
    
    if sort = listing_hash.delete(:sort)
      reverse = listing_hash.delete(:reverse) || false

      ferret_options[:sorting] = [Ferret::Search::SortField.new(sort, :reverse => reverse)]
    end
    
    query = listing_hash[:query] || ""

    listing_hash[:filters].each do |filter, filter_query|
      query += "_#{filter}:#{filter_query} "
    end
    
    ferret_options[:per_page] = params[options[:name]][:per_page] || 15

    results_container.settings[:filters] = listing_hash[:filters]
    results_container.search_results = self.find_with_ferret(query, ferret_options)
  
    results_container
  end
  
  listing_filter :name => :name, :account_name => lambda { account.name }, :groups => lambda { groups.join(' ') }
end
