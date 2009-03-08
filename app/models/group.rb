class Group < ActiveRecord::Base
  has_many :memberships
  has_many :people, :through => :memberships
  
  def to_s
    name
  end
end
