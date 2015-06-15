module Artanis
  module DSL
    {% for method in %w(head options get post put patch delete) %}
      macro {{ method.id }}(path, &block)
        match :{{ method.id }}, \{\{ path }} do \{\{ (block.args.empty? ? "" : "|#{block.args.argify}|").id }}
          \{\{ yield }}
        end
      end
    {% end %}

    # FIXME: block's original location is lost when passing args
    # TODO: support optional segments like "/posts/:id(.:format)" (?)
    macro match(method, path, &block)
      {%
        method_name = path
          .gsub(/\*[^\/.]+/, "_SPLAT_")
          .gsub(/:[^\/.]+/, "_PARAM_")
          .gsub(/\./, "_DOT_")
          .gsub(/\//, "_SLASH_")
          .id
      %}
      def match_{{ method.upcase.id }}_{{ method_name }}(%matchdata)
        {{ path.stringify }}
          .scan(/:([\w\d_]+)/)
          .each_with_index { |m, i| @params[m[1]] = %matchdata[i + 1] }

        {% if block.args.empty? %}
          {{ yield }}
        {% else %}
          {% for arg, index in block.args %}
            {{ arg.id }} = %matchdata[{{ index + 1 }}]
          {% end %}
          {{ block.body }}
        {% end %}
      end
    end
  end
end