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
  end

  def initialize(params={})
    build
    assign_parameters(params)
  end

  def assign_parameters(params)
    @params = params
    params.each do |key, value|
      self.send "#{key}=", value
    end
  end

  def build; end

  def persisted?
    false
  end

end
