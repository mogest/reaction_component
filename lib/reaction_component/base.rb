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
      "ReactionComponentMakeRequest(#{@_token.to_json}, #{method.to_s.to_json})"
    end

    def control_values
      @_values
    end

    def reaction_component_render
      reaction_component_javascript

      fine = @_view
      controller_name = @_view.controller.class.name

      @_view = nil

      data = {component: self, controller_name: controller_name}
      key = "reaction_component_#{@_token}"

      Rails.cache.write(key, Marshal.dump(data))

      @_values = {}

      @_view = fine
    end

    def reaction_component_javascript
      script <<-JS.html_safe
        function ReactionComponentMakeRequest(token, message) {
          var store;

          function save() {
            store = {};

            // TODO : this should be ALL controls, not just input
            $("input").each((_, input) => {
              if (input.id) {
                store[input.id] = $(input).val();
              }
            });
          }

          function load(updatedValues) {
            // TODO: don't depend on greenfields js stuff
            for (var key of Object.keys(store)) {
              $("#" + key).val(
                updatedValues.hasOwnProperty(key) ? updatedValues[key] : store[key]
              );
            }
          }

          save();

          var data = new FormData();
          data.append("token", token);
          data.append("msg", message);
          data.append("store", JSON.stringify(store));

          var opts = {
            method: "POST",
            body: data,
          };

          fetch("/reaction_component", opts)
            .then(r => r.text())
            .then(text => {
              var delimiterIndex = text.indexOf("\\n");

              if (delimiterIndex === -1) {
                throw new Error('you dun goofed');
              }

              var updatedValues = text.slice(0, delimiterIndex);
              var updatedHTML = text.slice(delimiterIndex);

              $("body").html(updatedHTML);

              load(JSON.parse(updatedValues));
            });
        }
      JS
    end
  end
end
