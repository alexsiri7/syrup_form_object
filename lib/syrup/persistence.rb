module Syrup::Persistence
  extend ActiveSupport::Concern

  included do
    include ActiveRecord::Persistence
    include ActiveRecord::Transactions
    include ActiveRecord::Validations

    extend ClassMethods
    include InstanceMethods
  end

  module ClassMethods
    def connection
      ActiveRecord::Base.connection
    end
  end

  module InstanceMethods
    def save_form
      self.related_objects.all?{|klass, related| related.save }
    end
  end

end
