require 'listing_fu'

ActiveRecord::Base.send :include, ListingFu
ActiveRecord::Associations::AssociationProxy.send :include, ListingFu::FindMethods

