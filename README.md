#Syrup::FormObject

This is a simple implementation of the FormObject... pattern?

##Installation

    gem install syrup_form_object

or in the *Gemfile*

    gem 'syrup_form_object'

##Examples

    class EventCreateForm < Syrup::FormObject
      attr_accessor :event
      accepts_nested_attributes_for :event

      attribute :length_of_the_event, Integer
      validates :length_of_the_event, numericality:{greater_than: 0}

      def save(params)
        if self.valid?
          end_date = event.start_date + length_of_the_event.hours
          event_attributes = params[:event_attributes].merge(end_date: end_date)
          event = Event.new(event_attributes)
          event.save
        else
          false
        end
      end
    end

##Some sources for Form Objects

https://github.com/apotonick/reform An implementation of Form Objects

http://railscasts.com/episodes/416-form-objects

http://pivotallabs.com/form-backing-objects-for-fun-and-profit/

http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/
