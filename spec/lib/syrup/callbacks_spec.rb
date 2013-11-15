require 'spec_helper'

class FakeConnection
  def transaction(params)
  end
end

class TestSubclassCallbacks < Syrup::FormObject
  standalone

  before_validation :fail_validate

  class << self
    def connection
      FakeConnection.new
    end
  end

  def fail_validate
    errors.add(:base, 'Invalid')
  end
end

describe TestSubclassCallbacks do
  it 'responds to save' do
    subject.save
  end

  it 'calls callbacks' do
    expect(subject.valid?).to be_false
  end
end
