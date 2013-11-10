require 'virtus'

class Syrup::FormObject
  include Virtus

  def self.accepts_nested_attributes_for(*relations)
    relations.each do |relation|
      module_eval "def #{relation}_attributes=(attributes); #{relation}.attributes=attributes; end"
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

end
