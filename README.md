#Syrup::FormObject

This is a simple implementation of the FormObject... pattern?

##Installation

    gem install syrup_form_object

or in the *Gemfile*

    gem 'syrup_form_object'

##Examples

To update the ```Event``` class in your model

    class Event < ActiveRecord::Base
      validates :start_date, presence: true
      validates :end_date, presence: true
    end

You create the follwing form

    class EventCreateForm < Syrup::FormObject
      has_one :event
      accepts_nested_attributes_for :event

      attribute :length_of_the_event, Integer
      validates :length_of_the_event, numericality:{greater_than: 0}

      def save
        if self.valid?
          end_date = event.start_date + length_of_the_event.hours
          event.end_date = end_date
          event.save
        else
          false
        end
      end
    end

Create a controller similar to this one

    class EventController < ApplicationController
      def new
        @event_form = EventCreateForm.new
      end

      def create
        @event_form = EventCreateForm.new(create_params)
        if @event_form.save
          redirect_to @event_form.event
        else
          render :new
        end
      end

      def create_params
        params.require(:event_create_form)
          .permit(:length_of_the_event)
          .permit(event_attributes: [:start_date])
      end
    end


And in the template:

    <%= form_for @event_form do %>
      <%= fields_for :event do %>
        <%= input_tag :start_date  %>
      <% end %>
      <%= input_tag :length_of_the_event  %>
    <% end %>


##Some sources for Form Objects

https://github.com/apotonick/reform An implementation of Form Objects

http://railscasts.com/episodes/416-form-objects

http://pivotallabs.com/form-backing-objects-for-fun-and-profit/

http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/
