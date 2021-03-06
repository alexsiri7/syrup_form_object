class Syrup::FormObject
  include Syrup::FormMethods
  extend ActiveModel::Callbacks
  include Syrup::Relations
  include Syrup::Persistence
  include Syrup::Callbacks

  class << self

    def wraps(klass)
      has_one(klass)
      @wrapped_class_name = klass
      include Syrup::Form::Wrapped
    end

    def standalone
      include Syrup::Form::Standalone
    end

    def find(params)
      form = self.new
      form.find_relations(params)
      form.after_find(params)
      form
    end

    def form_name(form_name)
      instance_eval <<-EOH
        def self.model_name
          ActiveModel::Name.new(self, nil, '#{form_name.to_s}')
        end
      EOH
    end
  end

  def remember_transaction_record_state(*); end
  def restore_transaction_record_state(*); end
  def clear_transaction_record_state(*); end
  def self.reflect_on_association(*); end
  def add_to_transaction; end
  def self.attributes_protected_by_default
    []
  end

  def initialize(params={})
    build_relations
    build(params)
    self.assign_attributes(params)
  end

  def update_attributes(params)
    self.assign_attributes(params)
    self.save
  end

  def build(params); end
  def after_find(params); end

  def run_validations!(*)
    super
    self.related_objects.each do |klass, related|
      unless related.valid?
        self.errors.add(klass, related.errors)
      end
    end
  end

  if Rails::VERSION::MAJOR >= 4

    def create_record
      run_callbacks(:create) {save_form}
    end

    def update_record(attributes=[])
      run_callbacks(:update) {save_form}
    end
  else
    def create
      run_callbacks(:create) { save_form }
    end

    def update(attributes=[])
      run_callbacks(:update) { save_form }
    end
  end

end
