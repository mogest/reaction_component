module ReactionComponent
  class Endpoint
    def initialize(app)
      @app = app
    end

    def call(env)
      # TODO : turn this into Rack middleware

      @app.call(env)
      return

      @component = Marshal.load Rails.cache.read(params[:token])

      if store = JSON.parse(params[:store])
        @component.instance_variable_set("@values", WriteHash.new(store))
      end

      @component.send(params[:msg])
      @component.try(:post_message)

      render inline: '<% @component.instance_variable_set("@_view", self); @component.view %>'
    end
  end
end
