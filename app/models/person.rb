class Person < ActiveRecord::Base
  has_many :memberships
  has_many :groups, :through => :memberships

  acts_as_ferret :fields => [:name, :group_description]
  
  def group_description
    "foo"
  end
end
