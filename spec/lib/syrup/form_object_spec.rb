require 'spec_helper'

class TestItem
  include Virtus.model
  attribute :test_item_value, Integer
end

class TestSubclass < Syrup::FormObject
  attribute :test_value, String
  has_one :test_item
  accepts_nested_attributes_for :test_item

  def build
    @built = true
  end

  def has_called_build?
    @built
  end

end

describe Syrup::FormObject do
  subject { TestSubclass.new(params) }
  let(:params) { {} }
  context '#new' do
    context 'with no attributes' do
      it 'creates a new object' do
        expect(subject).to be_a(Syrup::FormObject)
      end
      it 'calls the build method' do
        expect(subject).to have_called_build
      end
    end
    context 'with a params hash' do
      let(:params) {{ test_value: 'a Test',
                       test_item_attributes: {
                         test_item_value: '2'}}}
      it 'creates a new object' do
        expect(subject).to be_a(Syrup::FormObject)
      end
      it 'assigns the parameters in the right places' do
        expect(subject.test_value).to eq 'a Test'
      end
      it 'assigns the parameters in the nested attributes' do
        expect(subject.test_item.test_item_value).to eq 2
      end
    end
  end

  pending '#save'
  pending '::find'

end
