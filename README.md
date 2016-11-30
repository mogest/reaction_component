# ReactionComponent

A work in progress.

You'd be absolutely crazy to try to use this.

You might be instead looking for github.com/mogest/action_component?

## OK, fine.

```ruby
# app/components/counter_component.rb

class CounterComponent < ReactionComponent::Base
  def load
    @student = Student.new(name: "Quinoa")
  end

  def view
    div "Counter is #{@count}"
    div "% 3 is #{@count % 3}"

    form_for(@student, url: "#") do |f|
      f.text_field :name
    end

    button "Increment", onclick: callback(:increment)
    button "Decrement", onclick: callback(:decrement)
  end

  def increment
    @count += 1
  end

  def decrement
    @count -= 1
  end

  def after_message
    control_values["student_name"] += SecureRandom.hex[0] if @count == 5
  end
end
```

```ruby
# app/controllers/counter_controller.rb


class CounterController < ApplicationController
  def index
    render_component CounterComponent, count: 0
  end
end
```

```ruby
# config/routes.rb

Rails.application.routes.draw do
  root to: 'counter#index'

  # Temporary, have to add this to the gem initializer
  mount ReactionComponent::Endpoint.new(nil), at: '/reaction_component'
end
```

```ruby
# config/environments/development.rb

Rails.application.configure do
  config.cache_store = :memory_store
end
```
