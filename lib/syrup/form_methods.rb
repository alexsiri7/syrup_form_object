require 'virtus'

module Syrup::FormMethods
  extend ActiveSupport::Concern

  included do
    include Virtus.model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveRecord::AttributeAssignment
  end
end
