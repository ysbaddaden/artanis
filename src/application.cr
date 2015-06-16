require "./dsl"

module Artanis
  class Application
    include DSL

    getter :request, :params

    def initialize(@request)
      @params = {} of String => String
    end

    macro call_method(method)
      case request.path
      {{
        @type.methods
          .map(&.name.stringify)
          .select(&.starts_with?("match_#{method.id}"))
          .map { |method_name| "when #{ method_name.upcase.id }\n        new(request).#{ method_name.id }($~)" }
          .join("      \n")
          .id
      }}
      end
    end

    # OPTIMIZE: build a tree from path segments (?)
    macro def self.call(request) : String
      response = case request.method.upcase
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
      end

      response || "NOT FOUND: #{request.method} #{request.path}"
    end
  end
end
