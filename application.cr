require "./dsl"

module Artanis
  class Application
    include DSL

    getter :request, :params

    def initialize(@request)
      @params = {} of String => String
    end

    # OPTIMIZE: discriminate on methods first (?)
    # OPTIMIZE: build a tree from path segments (?)
    macro def self.call(request) : String
      case "match_#{request.method}_#{request.path}"
      {{
        @type.methods
          .map(&.name.stringify)
          .select(&.starts_with?("match_"))
          .map { |method|
            regexp = method
              .gsub(/_SPLAT_/, "(.*?)")
              .gsub(/_PARAM_/, "([^\\/]+)")
              .gsub(/_DOT_/, "\\.")
              .gsub(/_SLASH_/, "\\/")
              #.gsub(/_LPAREN_(.+?)_RPAREN_/, "(?:\1)")
              .gsub(/_LPAREN_/, "(?:")
              .gsub(/_RPAREN_/, ")?")
              .id
            "when /\\A#{ regexp }\\Z/ \n        new(request).#{ method.id }($~)"
          }
          .join("\n      ")
          .id
      }}
      else
        "NOT FOUND: #{request.method} #{request.path}"
      end
    end
  end
end
