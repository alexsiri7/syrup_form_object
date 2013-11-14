module Syrup::Form::Standalone
  extend ActiveSupport::Concern

  included do
    def self.model_name
      ActiveModel::Name.new(self, nil, self.class.name)
    end
  end

  def persisted?
    false
  end

  def new_record?
    true
  end


  def readonly?
    false
  end

  def wrapped?
    false
  end

end
