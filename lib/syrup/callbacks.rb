module Syrup::Callbacks
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Validations::Callbacks
    include ActiveSupport::Callbacks
    include ActiveRecord::Callbacks

    include InstanceMethods
  end

  module InstanceMethods
  end

end
