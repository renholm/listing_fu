require 'listing_fu'

ActionView::Base.send :include, ListingFu::Helper::HelperMethods

ActiveRecord::Base.send :include, ListingFu

ActiveRecord::Base.send :include, ListingFu::FindMethods
ActiveRecord::Associations::AssociationProxy.send :include, ListingFu::FindMethods

ActsAsFerret::SearchResults.send :include, ListingFu::SearchResultsExtentions