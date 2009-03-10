class Person < ActiveRecord::Base
  has_many :memberships
  has_many :groups, :through => :memberships

  has_one :account

  listing_filter :name => :name, :age => :age
  # listing_filter :name => :name, :age => :age, :account_name => lambda { account.name }, :groups => lambda { groups.join(' ') }
end
