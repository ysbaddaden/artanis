module Artanis
  module DSL
    FIND_PARAM_NAME = /:([\w\d_]+)/

    {% for method in %w(head options get post put patch delete) %}
      macro {{ method.id }}(path, &block)
        match {{ method }}, \{\{ path }} do \{\{ (block.args.empty? ? "" : "|#{block.args.argify}|").id }}
          \{\{ yield }}
        end
      end
    {% end %}

    # TODO: use __match_000000 routes to more easily support whatever in routes (?)
    # TODO: match regexp routes
    # TODO: add conditions on routes
    #
    # OPTIMIZE: split the route in segments (?) would help to avoid double gsub (?)
    macro match(method, path, &block)
      {%
        prepared = path
          .gsub(/\*[^\/.()]+/, "_SPLAT_")
          .gsub(/:[^\/.()]+/, "_PARAM_")
          .gsub(/\./, "_DOT_")
          .gsub(/\//, "_SLASH_")
          .gsub(/\(/, "_LPAREN_")
          .gsub(/\)/, "_RPAREN_")

        matcher = prepared
          .gsub(/_SPLAT_/, "(.*?)")
          .gsub(/_PARAM_/, "([^\\/]+)")
          .gsub(/_DOT_/, "\\.")
          .gsub(/_SLASH_/, "\\/")
          #.gsub(/_LPAREN_(.+?)_RPAREN_/, "(?:\1)")
          .gsub(/_LPAREN_/, "(?:")
          .gsub(/_RPAREN_/, ")?")

        method_name = prepared
          .gsub(/-/, "_MINUS_")
      %}
      MATCH_{{ method.upcase.id }}_{{ method_name.upcase.id }} = /\A{{ matcher.id }}\\Z/

      def match_{{ method.upcase.id }}_{{ method_name.id }}(matchdata)
        {{ path }}
          .scan(FIND_PARAM_NAME)
          .each_with_index do |m, i|
            if value = matchdata[i + 1]?
              @params[m[1]] = value
            end
          end

        {% for arg, index in block.args %}
          {{ arg.id }} = matchdata[{{ index + 1 }}]?
        {% end %}

        res = {{ yield }}

        if res.is_a?(Int)
          status res
        else
          body res
        end

        # see https://github.com/manastech/crystal/issues/821
        :ok
      end
    end

    macro halt(code_or_message = 200)
      {% if code_or_message.is_a?(NumberLiteral) %}
        status {{ code_or_message }}.to_i
      {% else %}
        body {{ code_or_message }}.to_s
      {% end %}
      return :halt
    end

    macro halt(code, message)
      status {{ code }}.to_i
      body {{ message }}.to_s
      return :halt
    end

    macro pass
      return :pass
    end
  end
end
