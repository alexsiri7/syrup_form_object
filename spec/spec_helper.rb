require 'rspec'

class String
  def constantize
    Object.const_get(self)
  end

  def camelize
    string = sub(/^[a-z\d]*/) { $&.capitalize }
    string.gsub(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }
  end
end

module ActiveModel
  module Naming; end
  module Conversion; end
  module Validations; end
end

require 'syrup'

RSpec.configure do |config|
end
