require 'active_support/core_ext/string'

module ReactionComponent
  class Endpoint
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      params = request.params

      unless request.post?
        return [405, nil, ['Invalid method']]
      end

      key = "reaction_component_#{params['token']}"
      serialised_data = Rails.cache.read(key)

      if serialised_data.nil?
        return [404, {}, ['File not found']]
      end

      data = Marshal.load(serialised_data)

      @component = data[:component]
      controller = data[:controller_name].constantize

      if store = JSON.parse(params['store'])
        @component.instance_variable_set("@_values", WriteHash.new(store))
      end

      @component.send(params['msg'])

      output = controller.new.render_to_string(
        inline: '<% @component.instance_variable_set("@_view", self); @component.render_view %>',
        locals: {:@component => @component}
      )

      [200, {"Content-Type" => "text/html"}, [output]]
    end
  end
end
