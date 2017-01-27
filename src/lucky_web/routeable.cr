module LuckyWeb::Routeable
  macro included
    add_route_and_helpers
  end

  macro add_route_and_helpers
    {% resource = @type.name.split("::").first.underscore %}
    {% action_name = @type.name.split("::").last.gsub(/Action/, "").underscore %}

    {% if action_name == "index" %}
      {% path = "/#{resource.id}" %}

      def self.route
        {{path}}
      end
    {% elsif action_name == "new" %}
      {% path = "/#{resource.id}/new" %}

      def self.route
        {{path}}
      end
    {% elsif action_name == "show" %}
      {% path = "/#{resource.id}/:id" %}

      def self.route(id)
        "/{{resource.id}}/#{id}"
      end
    {% else %}
      {% raise(
           <<-ERROR
        Could not infer route for #{@type.name}

        Got:
          #{@type.name} (missing a known resourceful action)

        Expected something like:
          ResourceName::IndexAction # Index, Show, New, Create, Edit, Update, or Delete
        ERROR
         ) %}
    {% end %}

    LuckyWeb::Router.add({{path}}, {{@type.name.id}})
  end
end