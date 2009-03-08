require 'acts_as_ferret'

module ListingFu
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval { include InstanceMethods }
  end
  
  module ClassMethods
    
  end
  
  module InstanceMethods

  end
end