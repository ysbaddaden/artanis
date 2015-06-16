require "./dsl"
require "http/response"

class HTTP::Response
  setter :status_code

  def body=(str)
    @body = str
    @headers["Content-Length"] = str.bytesize.to_s
  end
end

module Artanis
  # TODO: pass helper to skip to next route
  # TODO: halt helper to exit the current route immediately
  # TODO: etag helper to set http etag + last-modified headers and skip request if-modified-since
  # TODO: before(path, &block) and after(path, &block) macros
  # TODO: error(code, &block) macro to install handlers for returned statuses
  class Application
    include DSL

    getter :request, :response, :params

    # TODO: parse query string and populate @params
    # TODO: parse request body and populate @params (?)
    def initialize(@request)
      @params = {} of String => String
      @response = HTTP::Response.new(200, nil)
    end

    def status(code)
      @response.status_code = code.to_i
    end

    def body(str)
      @response.body = str.to_s
    end

    def headers(hsh)
      hsh.each { |k, v| @response.headers.add(k.to_s, v.to_s) }
    end

    def redirect(uri)
      @response.headers["Location"] = uri.to_s
    end

    def not_found
      status 404
      body yield
    end

    # TODO: flatten case to a bunch of if (to support "pass")
    macro call_method(method)
      app = new(request)

      case request.path
      {{
        @type.methods
          .map(&.name.stringify)
          .select(&.starts_with?("match_#{method.id}"))
          .map { |method_name| "when #{ method_name.upcase.id }\n         app.#{ method_name.id }($~)" }
          .join("        \n")
          .id
      }}
      else
        app.no_such_route
      end

      app
    end

    # OPTIMIZE: build a tree from path segments (?)
    macro def self.call(request) : HTTP::Response
      case request.method.upcase
      {{
        @type.methods
          .map(&.name.stringify)
          .select(&.starts_with?("match_"))
          .map { |method_name| method_name.split("_")[1] }
          .uniq
          .map { |method| "when #{method}\n        call_method(#{method}).response" }
          .join("\n      ")
          .id
      }}
      else
        new(request).tap(&.no_such_route).response
      end
    end

    protected def no_such_route
      not_found { "NOT FOUND: #{request.method} #{request.path}" }
    end
  end
end
