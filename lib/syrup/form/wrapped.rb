module Syrup::Form::Wrapped
  extend ActiveSupport::Concern

  included do
    alias_method :wrapped, @wrapped_class_name
    alias_method :wrapped=, "#{@wrapped_class_name}="
    @wrapped_class = @wrapped_class_name.to_s.camelize.constantize

    def self.method_missing(*params)
      @wrapped_class.send *params
    end

    def self.respond_to?(*params)
      super || @wrapped_class.respond_to?(*params)
    end

    def self.model_name
      @wrapped_class.model_name
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
