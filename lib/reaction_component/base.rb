module ReactionComponent
  class Base < ActionComponent::Base
    after_render :reaction_component_render

    def initialize(*)
      super

      @_values = {}
      @_token ||= SecureRandom.hex
    end

    private

    def callback(method)
      "go(#{method.to_s.to_json})"
    end

    def reaction_component_render
      script <<-JS.html_safe
        let store;

        function save() {
          store = {};
          $("input").each((_, input) => {
            if (input.id) {
              store[input.id] = $(input).val();
            }
          });
        }

        function load(values) {
          for (const key of Object.keys(store)) {
            $("#" + key).val(
              values.hasOwnProperty(key) ? values[key] : store[key]
            );
          }
        }

        function go(msg) {
          save();

          const data = new FormData();
          data.append("token", "#{@_token}");
          data.append("msg", msg);
          data.append("store", JSON.stringify(store));

          const opts = {
            method: "POST",
            body: data,
          };

          fetch("/reaction_component", opts)
            .then(r => r.text())
            .then(text => {
              $("body").html(text);
              const values = #{@_values.to_json};
              load(values);
            });
        }
      JS

      fine = @_view
      controller_name = @_view.controller.class.name

      @_view = nil

      data = {component: self, controller_name: controller_name}
      key = "reaction_component_#{@_token}"

      Rails.cache.write(key, Marshal.dump(data))

      @_values = {}

      @_view = fine
    end
  end
end
