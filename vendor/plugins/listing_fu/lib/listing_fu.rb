require 'acts_as_ferret'
require 'will_paginate'

module ListingFu
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval { include InstanceMethods }
  end
  
  module ClassMethods
    def listing_filter(filters)
      fields = {}

      filters.each do |name, definition|
        method_declaration = lambda do
          if definition.is_a? Proc
            self.instance_eval &definition
          elsif definition.is_a? Symbol or definition.is_a? String
            self.send definition
          else
            raise 'Error: Filter needs to be either a Symbol, String or a Proc'
          end
        end

        define_method "_#{name.to_s}", &method_declaration
        define_method "_#{name.to_s}_sort", &method_declaration

        fields["_#{name.to_s}"] = {}
        fields["_#{name.to_s}_sort"] = {:index => :untokenized}
      end

      acts_as_ferret :fields => fields, :remote => true
    end
  end
  
  module InstanceMethods

  end
end