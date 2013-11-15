require 'virtus'

class Syrup::FormObject
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  extend ActiveModel::Callbacks

  include ActiveRecord::Persistence
  include ActiveRecord::Transactions
  include ActiveRecord::Validations
  include ActiveModel::Validations::Callbacks
  include ActiveSupport::Callbacks
  include ActiveRecord::Callbacks

  class << self

    def accepts_nested_attributes_for(*relations)
      relations.each do |relation|
        build_attributes_setter relation
      end
    end

    # build_attributes_setter 'address'
    #
    # def address_attributes=(attributes)
    #   address.attributes=attributes
    # end

    def build_attributes_setter(relation)
      module_eval <<-EOH
        def #{relation}_attributes=(attributes)
          #{relation}.attributes=attributes
        end
      EOH
    end

    def relations
      @relations ||= []
    end

    def has_one(klass)
      relations << klass
      attr_accessor klass
    end


    def wraps(klass)
      has_one(klass)
      @wrapped_class = klass
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

    def connection
      ActiveRecord::Base.connection
    end

  end

  def remember_transaction_record_state(*); end
  def restore_transaction_record_state(*); end

  def initialize(params={})
    build_relations
    build(params)
    self.attributes=params
  end

  def update_attributes(params)
    self.attributes=params
    self.save
  end

  def build_relations
    self.class.relations.each do |klass|
      self.send "#{klass}=", klass.to_s.camelize.constantize.new
    end
  end

  def find_relations(params)
    self.class.relations.each do |klass|
      if params[klass]
        self.send "#{klass}=", klass.to_s.camelize.constantize.find(params[klass])
      end
    end
  end

  def attributes=(params)
    @params = params
    params.each do |key, value|
      self.send "#{key}=", value
    end
  end

  def build(params); end
  def after_find(params); end

  def before_save; end
  def before_create; end
  def after_create; end
  def after_save; end
  def after_commit; end

  def transaction(&block)
    first_related_object.transaction(&block)
  end

  def first_related_object
    respond_to?(:wrapped) ? wrapped : self.send(self.class.relations.first)
  end

  def related_objects
    related= {}
    self.class.relations.collect do |klass|
      related[klass] = self.send(klass)
    end
    related
  end


  def add_to_transaction; end

  def run_validations!(*)
    super
    self.related_objects.each do |klass, related|
      unless related.valid?
        self.errors.add(klass, related.errors)
      end
    end
  end

  def create_record
    save_form
  end

  def update_record
    save_form
  end

  def create
    run_callbacks(:create) { save_form }
  end

  def update
    run_callbacks(:update) { save_form }
  end

  def save_form
    self.related_objects.all?{|klass, related| related.save }
  end

end
