require 'spec_helper'

class TestItem
  include Virtus.model
  attribute :test_item_value, Integer

  def self.find(id)
  end

  def save
  end

  def transaction
    yield
  end

  def persisted?
    false
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

  def after_save
    @after_save = true
  end

  def has_called_after_save?
    @after_save
  end

  def after_create
    @after_create = true
  end

  def has_called_after_create?
    @after_create
  end

  def after_commit
    @after_commit = true
  end

  def has_called_after_commit?
    @after_commit
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

    describe '#save' do
      let(:params) { {} }
      subject { test_subclass.new(params) }
      it 'calls after_save' do
        subject.save

        expect(subject).to have_called_after_save
      end
    end

    describe '#persisted?' do
      let(:params) { {} }
      subject { test_subclass.new(params) }
      it 'returns false' do
        expect(subject.persisted?).to be_false
      end
    end

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

    describe '#save' do
      let(:params) {{ test_item_attributes: {
                           test_item_value: '2'}}}
      subject { test_subclass.new(params) }
      it 'saves the test_item' do
        subject.test_item.should_receive(:save)

        subject.save
      end
      it 'calls after_save' do
        subject.save

        expect(subject).to have_called_after_save
      end
    end

    describe '#persisted?' do
      let(:params) {{ test_item_attributes: {
                           test_item_value: '2'}}}
      subject { test_subclass.new(params) }
      it 'returns false' do
        expect(subject.persisted?).to be_false
      end
    end
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
      let(:test_item) { TestItem.new }

      it 'loads the test_item from the id sent' do
        TestItem.should_receive(:find).with(params) { test_item }

        expect(subject.wrapped).to be test_item
      end
      it 'calls the after_find method' do
        expect(subject).to have_called_after_find
      end
    end

    describe '#save' do
      let(:params) {{ test_item_value: '2' }}

      subject { test_subclass.new(params) }
      it 'saves the test_item' do
        subject.test_item.should_receive(:save)

        subject.save
      end
      it 'calls after_save' do
        subject.save

        expect(subject).to have_called_after_save
      end
      context 'when the object is new' do
        it 'calls after_create' do
          subject.wrapped.stub(:persisted?) { false }

          subject.save

          expect(subject).to have_called_after_create
        end
      end
      context 'when the object is not new' do
        it 'calls after_update' do
          subject.wrapped.stub(:persisted?) { true }

          subject.save

          expect(subject).not_to have_called_after_create
        end
      end
    end

    describe '#persisted?' do
      let(:params) {{ test_item_value: '2' }}
      subject { test_subclass.find(params) }
      it 'forwards the message to the wrapped object' do
        subject.wrapped.stub(:persisted?) {:a_value}

        expect(subject.persisted?).to be :a_value
      end
    end
  end

end
