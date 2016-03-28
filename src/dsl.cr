module Artanis
  # TODO: error(code, &block) macro to install handlers for returned statuses
  module DSL
    FIND_PARAM_NAME = /:([\w\d_]+)/

    {% for method in %w(head options get post put patch delete) %}
      macro {{ method.id }}(path, &block)
        match {{ method }}, \{\{ path }} do \{\{ (block.args.empty? ? "" : "|#{block.args.argify}|").id }}
          \{\{ yield }}
        end
      end
    {% end %}

    macro match(method, path, &block)
      gen_match "match", {{ method }}, {{ path }}, {{ block }}
    end

    macro before(path = "*", &block)
      gen_match "before", nil, {{ path }}, {{ block }}
    end

    macro after(path = "*", &block)
      gen_match "after", nil, {{ path }}, {{ block }}
    end

    # TODO: use __match_000000 routes to more easily support whatever in routes (?)
    # TODO: match regexp routes
    # TODO: add conditions on routes
    #
    # OPTIMIZE: split the route in segments (?) would help to avoid double gsub (?)
    macro gen_match(type, method, path, &block)
      {%
       prepared = path
          .gsub(/\*[^\/.()]+/, "_SPLAT_")
          .gsub(/\*/, "_ANY_")
          .gsub(/:[^\/.()]+/, "_PARAM_")
          .gsub(/\./, "_DOT_")
          .gsub(/\//, "_SLASH_")
          .gsub(/\(/, "_LPAREN_")
          .gsub(/\)/, "_RPAREN_")

        matcher = prepared
          .gsub(/_SPLAT_/, "(.*?)")
          .gsub(/_ANY_/, ".*?")
          .gsub(/_PARAM_/, "([^\\/.]+)")
          .gsub(/_DOT_/, "\\.")
          .gsub(/_SLASH_/, "\\/")
          #.gsub(/_LPAREN_(.+?)_RPAREN_/, "(?:\1)")
          .gsub(/_LPAREN_/, "(?:")
          .gsub(/_RPAREN_/, ")?")

        method_name = prepared
          .gsub(/-/, "_MINUS_")

        method_name = "#{method.upcase.id}_#{method_name.id}" if method
      %}
      {{ type.upcase.id }}_{{ method_name.upcase.id }} = /\A{{ matcher.id }}\Z/

      def {{ type.id }}_{{ method_name.id }}(matchdata)
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

        {% if type == "match" %}
          if res.is_a?(Int)
            status res
          else
            body res
          end
        {% end %}

        # see https://github.com/manastech/crystal/issues/821
        :ok
      end
    end

    macro call_action(method_name)
      if %m = URI.unescape(request.path || "/").match({{ method_name.upcase.id }})
        %ret = {{ method_name.id }}(%m)

        {% if method_name.starts_with?("match_") %}
          break unless %ret == :pass
        {% end %}
      end
    end

    macro call_method(method)
      {% method_names = @type.methods.map(&.name.stringify) %}

      {{
        method_names
          .select(&.starts_with?("before_"))
          .map { |method_name| "call_action #{ method_name }" }
          .join("\n        ")
          .id
      }}

      while 1
        {{
          method_names
            .select(&.starts_with?("match_#{method.id}"))
            .map { |method_name| "call_action #{ method_name }" }
            .join("\n        ")
            .id
        }}

        no_such_route
        break
      end

      {{
        method_names
          .select(&.starts_with?("after_"))
          .map { |method_name| "call_action #{ method_name }" }
          .join("\n        ")
          .id
      }}
    end

    # OPTIMIZE: build a tree from path segments (?)
    macro def call : Artanis::Response
      {% if @type.methods.size > 0 %}
        case request.method.upcase
        {{
          @type.methods
            .map(&.name.stringify)
            .select(&.starts_with?("match_"))
            .map { |method_name| method_name.split("_")[1] }
            .uniq
            .map { |method| "when #{method}\n        call_method(#{method})" }
            .join("\n      ")
            .id
        }}
        else
          no_such_route
        end
      {% else %}
        no_such_route
      {% end %}

      response.write_body
      response
    end
    
    macro logging(enable)
      {% if enable == true %}
        @log.addentry(request, response.status_code)
      {% end %}
    end

    macro setlogfile
      @log.setlogfile(logfilename)
    end
    
    ALWAYS_TRUE = true

    macro halt(code_or_message = 200)
      {% if code_or_message.is_a?(NumberLiteral) %}
        status {{ code_or_message }}.to_i
      {% else %}
        body {{ code_or_message }}.to_s
      {% end %}
      return :halt if ALWAYS_TRUE
    end

    macro halt(code, message)
      status {{ code }}.to_i
      body {{ message }}.to_s
      return :halt if ALWAYS_TRUE
    end

    macro pass
      return :pass if ALWAYS_TRUE
    end
  end
end
