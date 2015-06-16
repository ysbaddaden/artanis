module Artanis
  module DSL
    {% for method in %w(head options get post put patch delete) %}
      macro {{ method.id }}(path, &block)
        match {{ method }}, \{\{ path }} do \{\{ (block.args.empty? ? "" : "|#{block.args.argify}|").id }}
          \{\{ yield }}
        end
      end
    {% end %}

    # FIXME: block's original location is lost when passing args
    # TODO: replace special chars in routes
    macro match(method, path, &block)
      {%
        prepared = path
          .gsub(/\*[^\/.()]+/, "_SPLAT_")
          .gsub(/:[^\/.()]+/, "_PARAM_")
          .gsub(/\./, "_DOT_")
          .gsub(/\//, "_SLASH_")
          .gsub(/\(/, "_LPAREN_")
          .gsub(/\)/, "_RPAREN_")

        method_name = prepared
          .gsub(/-/, "_MINUS_")

        matcher = prepared
          .gsub(/_SPLAT_/, "(.*?)")
          .gsub(/_PARAM_/, "([^\\/]+)")
          .gsub(/_DOT_/, "\\.")
          .gsub(/_SLASH_/, "\\/")
          #.gsub(/_LPAREN_(.+?)_RPAREN_/, "(?:\1)")
          .gsub(/_LPAREN_/, "(?:")
          .gsub(/_RPAREN_/, ")?")
      %}
      MATCH_{{ method.upcase.id }}_{{ method_name.upcase.id }} = /\A{{ matcher.id }}\\Z/

      def match_{{ method.upcase.id }}_{{ method_name.id }}(%matchdata)
        {{ path }}
          .scan(/:([\w\d_]+)/)
          .each_with_index do |m, i|
            if %value = %matchdata[i + 1]?
              @params[m[1]] = %value
            end
          end

        {% if block.args.empty? %}
          {{ yield }}
        {% else %}
          {% for arg, index in block.args %}
            {{ arg.id }} = %matchdata[{{ index + 1 }}]?
          {% end %}
          {{ block.body }}
        {% end %}
      end
    end
  end
end
