require 'virtus'

class Syrup::FormObject
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  class << self
    def accepts_nested_attributes_for(*relations)
      relations.each do |relation|
        build_attributes_setter relation
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

    def has_one(klass)
      relations << klass
      attr_accessor klass
    end


    def wraps(klass)
      has_one(klass)
      alias_method :wrapped, klass
      alias_method :wrapped=, "#{klass}="
    end

    def find(params)
      form = self.new
      form.find_relations(params)
      form.after_find(params)
      form
    end

  end

  def method_missing(*params)
    wrapped.send *params
  end

  def responds_to?(*params)
    super || wrapped.responds_to?(*params)
  end

  def initialize(params={})
    build_relations
    build(params)
    assign_parameters(params)
  end

  def build_relations
    self.class.relations.each do |klass|
      self.send "#{klass}=", klass.to_s.camelize.constantize.new
    end
  end

  def find_relations(params)
    if params.is_a?(Hash)
      self.class.relations.each do |klass|
        if params[klass]
          self.send "#{klass}=", klass.to_s.camelize.constantize.find(params[klass])
        end
      end
    else
      self.wrapped= self.wrapped.class.find(params)
    end
  end

  def assign_parameters(params)
    @params = params
    params.each do |key, value|
      self.send "#{key}=", value
    end
  end

  def build(params); end
  def after_find(params); end
  def after_create; end
  def after_save; end
  def after_commit; end

  def persisted?
    respond_to?(:wrapped) && wrapped.persisted?
  end

  def transaction(&block)
    first_related_object.transaction(&block)
  end

  def first_related_object
    respond_to?(:wrapped) ? wrapped : self.send(self.class.relations.first)
  end

  def save
    if self.class.relations.empty?
      after_save
    else
      new_object= !persisted?
      transaction do
        self.class.relations.each do |klass|
          self.send(klass).save
        end
        if new_object
          after_create
        end
        after_save
      end
      after_commit
    end
  end

end
