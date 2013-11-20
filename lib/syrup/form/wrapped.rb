module Syrup::Form::Wrapped
  extend ActiveSupport::Concern

  included do
    alias_method :wrapped, @wrapped_class
    alias_method :wrapped=, "#{@wrapped_class}="

    def self.model_name
      @wrapped_class.to_s.camelize.constantize.model_name
    end
  end

  def method_missing(*params)
    wrapped.send *params
  end

  def respond_to?(*params)
    super || wrapped.respond_to?(*params)
  end

  def find_relations(params)
    if params.is_a?(Hash)
      super(params)
    else
      self.wrapped= self.wrapped.class.find(params)
    end
  end

  def wrapped?
    true
  end

  def new_record?
    wrapped.new_record?
  end

  def persisted?
    wrapped.persisted?
  end


end

