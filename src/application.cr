require "./dsl"
require "./render"
require "http/response"

class HTTP::Response
  setter :status_code

  def body=(str)
    @body = str
    @headers["Content-Length"] = str.bytesize.to_s
  end
end

module Artanis
  # TODO: etag helper to set http etag + last-modified headers and skip request if-modified-since
  class Application
    include DSL
    include Render

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

    def self.call(request)
      new(request).call
    end

    private def no_such_route
      not_found { "NOT FOUND: #{request.method} #{request.path}" }
    end

    macro inherited
      views_path "views"
    end
  end
end
