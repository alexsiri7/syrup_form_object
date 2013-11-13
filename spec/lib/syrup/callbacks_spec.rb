require 'spec_helper'


class TestSubclass < Syrup::FormObject
  standalone

  before_validation :fail_validate

  def fail_validate
    false
  end
end

describe TestSubclass do
  it 'responds to save' do
    subject.save
  end
  it 'calls callbacks' do
    expect(subject.valid?).to be_false
  end
end
