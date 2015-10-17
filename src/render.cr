require "ecr/macros"

module Artanis
  # TODO: render views in subpaths (eg: views/blog/posts/show.ecr => render_blog_posts_show_ecr)
  module Render
    macro ecr(name, layout = "layout")
      render {{ name }}, "ecr", layout: {{ layout }}
    end

    macro render(name, engine, layout = "layout")
      {% if layout %}
        render_{{ layout.id }}_{{ engine.id }} do
          render_{{ name.id }}_{{ engine.id }}
        end
      {% else %}
        render_{{ name.id }}_{{ engine.id }}
      {% end %}
    end

    macro views_path(path)
      {%
        views = `cd #{ path } 2>/dev/null && ls *.ecr || echo -n ""`
          .lines
          .map(&.strip.gsub(/\.ecr/, ""))
      %}

      {% for view in views %}
        def render_{{ view.id }}_ecr
          render_{{ view.id }}_ecr {}
        end

        def render_{{ view.id }}_ecr(&block)
          String.build do |__str__|
            embed_ecr "{{ path.id }}/{{ view.id }}.ecr", "__str__"
          end
        end
      {% end %}
    end
  end
end
