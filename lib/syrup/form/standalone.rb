module Syrup::Form::Standalone
  extend ActiveSupport::Concern

  included do
    extend ClassMethods
  end

  module ClassMethods
    def connection
      ActiveRecord::Base.connection
    end
  end

  def persisted?
    false
  end

  def readonly?
    false
  end

  def wrapped?
    false
  end
end
