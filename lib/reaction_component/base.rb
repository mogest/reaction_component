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

    def control_values
      @_values
    end

    def reaction_component_render
      div "", id: "reaction-component-updated-values-#{@_token}", "data-json" => @_values.to_json

      script <<-JS.html_safe
        const token = #{@_token.to_json};
        let store;

        function save() {
          store = {};
          $("input").each((_, input) => {
            if (input.id) {
              store[input.id] = $(input).val();
            }
          });
        }

        function load(updatedValues) {
          for (const key of Object.keys(store)) {
            $("#" + key).val(
              updatedValues.hasOwnProperty(key) ? updatedValues[key] : store[key]
            );
          }
        }

        function go(msg) {
          save();

          const data = new FormData();
          data.append("token", token);
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

              const updatedValues = $("#reaction-component-updated-values-" + token).data("json");
              load(updatedValues);
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
