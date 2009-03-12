require 'acts_as_ferret'
require 'will_paginate'

module ListingFu
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def listing_filter(filters)
      @available_filters = []

      fields = {}

      filters.each do |name, definition|
        method_declaration = lambda do
          if definition.is_a? Proc
            self.instance_eval(&definition).to_s.downcase
          elsif definition.is_a? Symbol or definition.is_a? String
            self.send(definition).to_s.downcase
          else
            raise 'Error: Filter needs to be either a Symbol, String or a Proc'
          end
        end

        @available_filters << name

        define_method "_#{name.to_s}", &method_declaration
        define_method "_#{name.to_s}_sort", &method_declaration

        fields["_#{name.to_s}"] = {}
        fields["_#{name.to_s}_sort"] = {:index => :untokenized}
      end

      # save the available filters in the class for use in the view later on
      (class << self; self; end).class_eval do
        def _available_filters
          @available_filters
        end
      end

      acts_as_ferret :fields => fields, :remote => true
    end
  end
end