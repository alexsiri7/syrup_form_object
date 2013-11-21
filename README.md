#Syrup::FormObject

[![Gem Version](https://badge.fury.io/rb/syrup_form_object.png)][gem]
[![Build Status](https://travis-ci.org/alexsiri7/syrup_form_object.png?branch=master)][travis]

[gem]: http://badge.fury.io/rb/syrup_form_object
[travis]: https://travis-ci.org/alexsiri7/syrup_form_object


This is a simple implementation of the FormObject... pattern?

##Installation
``` terminal
$ gem install syrup_form_object
```

or in the *Gemfile*
``` ruby
gem 'syrup_form_object'
```

##Examples

Note: The following example can be found in [syrup_form_example](https://github.com/alexsiri7/syrup_form_example)

To update the ```Event``` class in your model
``` ruby
class Event < ActiveRecord::Base
  validates :start_date, presence: true
  validates :end_date, presence: true
end
```

You create the follwing form

``` ruby
class EventForm < Syrup::FormObject
  wraps :event

  attribute :length_of_the_event, Integer
  validates :length_of_the_event, numericality: {greater_than: 0}

  before_validation :before_validation

  def before_validation
    self.end_date = event.start_date + length_of_the_event.to_i.hours
  end
end
```

Create a controller similar to this one

``` ruby
class EventController < ApplicationController
  def new
    @event_form = EventForm.new
  end

  def create
    @event_form = EventForm.new(create_params)
    if @event_form.save
      redirect_to @event_form.event
    else
      render :new
    end
  end

  def create_params
    params.require(:event)
      .permit(:length_of_the_event, :start_date)
  end
end
```

And in the template:

``` erb
<%= form_for @event_form do %>
  <%= input_tag :start_date  %>
  <%= input_tag :length_of_the_event  %>
<% end %>
```


##Some sources for Form Objects

https://github.com/apotonick/reform An implementation of Form Objects

http://railscasts.com/episodes/416-form-objects

http://pivotallabs.com/form-backing-objects-for-fun-and-profit/

http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/
