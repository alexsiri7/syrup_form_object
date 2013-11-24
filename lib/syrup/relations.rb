module Syrup::Relations
  extend ActiveSupport::Concern

  included do
    extend ClassMethods

    include InstanceMethods
  end

  module ClassMethods
    def accepts_nested_attributes_for(*relations)
      relations.each do |relation|
        build_attributes_setter relation
        add_relation(relation)
      end
    end

    # build_attributes_setter 'address'
    #
    # def address_attributes=(attributes)
    #   address.attributes=attributes
    # end

    def build_attributes_setter(relation)
      module_eval <<-EOH
        def #{relation}_attributes=(attributes)
          #{relation}.attributes=attributes
        end
      EOH
    end

    def relations
      @relations ||= []
    end

    def add_relation(klass)
      relations << klass unless relations.include?(klass)
    end

    def has_one(klass)
      add_relation(klass)
      attr_accessor klass
    end
  end

  module InstanceMethods
    def build_relations
      self.class.relations.each do |klass|
        self.send "#{klass}=", klass.to_s.camelize.constantize.new
      end
    end

    def find_relations(params)
      self.class.relations.each do |klass|
        if params[klass]
          self.send "#{klass}=", klass.to_s.camelize.constantize.find(params[klass])
        end
      end
    end

    def first_related_object
      respond_to?(:wrapped) ? wrapped : self.send(self.class.relations.first)
    end


    def related_objects
      related= {}
      self.class.relations.collect do |klass|
        related[klass] = self.send(klass)
      end
      related
    end
  end

end
