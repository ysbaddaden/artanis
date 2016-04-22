require "./dsl"
require "./render"
require "./response"
require "http/server"

module Artanis
  # TODO: etag helper to set http etag + last-modified headers and skip request if-modified-since
  class Application
    include DSL
    include Render

    getter :context, :params

    # TODO: parse query string and populate @params
    # TODO: parse request body and populate @params (?)
    def initialize(@context : HTTP::Server::Context)
      @params = {} of String => String
    end

    def request
      context.request
    end

    def response
      @response ||= Response.new(context.response)
    end

    def status(code)
      response.status_code = code.to_i
    end

    def body(str)
      response.body = str
    end

    def headers(hsh)
      hsh.each { |k, v| response.headers.add(k.to_s, v.to_s) }
    end

    def redirect(uri)
      response.headers["Location"] = uri.to_s
    end

    def not_found
      status 404
      body yield
    end

    def self.call(context)
      new(context).call
    end

    private def no_such_route
      not_found { "NOT FOUND: #{request.method} #{request.path}" }
    end

    macro inherited
      views_path "views"
    end
  end
end
