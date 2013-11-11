require 'spec_helper'

class TestItem
  include Virtus.model
  attribute :test_item_value, Integer

  def self.find(id)
  end
end

class TestSubclass < Syrup::FormObject
  def build(params)
    @built = true
  end

  def has_called_build?
    @built
  end

  def after_find(params)
    @after_find = true
  end

  def has_called_after_find?
    @after_find
  end
end

shared_examples 'successful create' do
  it 'creates a new object' do
    expect(subject).to be_a(Syrup::FormObject)
  end
  it 'calls the build method' do
    expect(subject).to have_called_build
  end
end

describe Syrup::FormObject do
  context 'when using simple attributes' do
    let(:test_subclass) {
      Class.new(TestSubclass) do
        attribute :test_value, String
      end
    }

    describe '#new' do
      subject { test_subclass.new(params) }
      let(:params) { {} }
      include_examples 'successful create'
      context 'with a params hash' do
        let(:params) { {test_value: 'a Test'} }

        include_examples 'successful create'

        it 'assigns the parameters in the right places' do
          expect(subject.test_value).to eq 'a Test'
        end
      end
    end

    describe '::find' do
      subject { test_subclass.find(params) }
      let(:params) { {} }
      it 'calls the after_find method' do
        expect(subject).to have_called_after_find
      end
    end

    pending '#save'
  end
  context 'when using nested attributes' do
    let(:test_subclass) {
      Class.new(TestSubclass) do
        has_one :test_item
        accepts_nested_attributes_for :test_item
      end
    }
    describe '#new' do
      subject { test_subclass.new(params) }
      let(:params) { {} }
      include_examples 'successful create' do
        it 'creates the nested object' do
          expect(subject.test_item).to be_a(TestItem)
        end
      end

      context 'with a params hash' do
        let(:params) {{ test_item_attributes: {
                           test_item_value: '2'}}}

        include_examples 'successful create'

        it 'assigns the parameters in the nested attributes' do
          expect(subject.test_item.test_item_value).to eq 2
        end
      end
    end

    describe '::find' do
      subject { test_subclass.find(params) }
      let(:params) { {test_item: 2} }

      it 'loads the test_item from the attributes sent' do
        TestItem.should_receive(:find).once { TestItem.new }

        expect(subject.test_item).to be_a(TestItem)
      end
      it 'calls the after_find method' do
        expect(subject).to have_called_after_find
      end
    end

    pending '#save'
  end

  context 'when using a wrapped object' do
    let(:test_subclass) {
      Class.new(TestSubclass) do
        wraps :test_item
      end
    }
    describe '#new' do
      subject { test_subclass.new(params) }
      let(:params) { {} }
      include_examples 'successful create' do
        it 'creates the wrapped object' do
          expect(subject.test_item).to be_a(TestItem)
        end

        it 'creates the wrapped object' do
          expect(subject.wrapped).to be_a(TestItem)
        end
      end

      context 'with a params hash' do
        let(:params) {{ test_item_value: '2' }}

        include_examples 'successful create' do
          it 'creates the wrapped object' do
            expect(subject.test_item).to be_a(TestItem)
          end

          it 'creates the wrapped object' do
            expect(subject.wrapped).to be_a(TestItem)
          end
        end

        it 'assigns the parameters to the object' do
          expect(subject.test_item.test_item_value).to eq 2
        end

        it 'has an accesor to the parameter' do
          expect(subject.test_item_value).to eq 2
        end
      end
    end

    describe '::find' do
      subject { test_subclass.find(params) }
      let(:params) { 2 }

      it 'loads the test_item from the id sent' do
      end
      it 'calls the after_find method' do
        expect(subject).to have_called_after_find
      end
    end

    pending '#save'
  end

end
