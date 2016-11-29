module ReactionComponent
  class Base < ActionComponent::Base
    def initialize(*)
      super

      @_values = {}
      @_token ||= SecureRandom.hex
    end

    def post_view
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
            console.log(values.hasOwnProperty(key), values[key], store[key])

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

          fetch("/endpoint", opts)
            .then(r => r.text())
            .then(text => {
              $("body").html(text);
              const values = #{@_values.to_json};
      console.log(values);
              load(values);
            });
        }
      JS

      fine = @_view
      @_view = nil
      Store[@_token] = Marshal.dump(self)
      @_values = {}

      @_view = fine
    end
  end
end
