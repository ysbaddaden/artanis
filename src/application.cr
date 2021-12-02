require "./dsl"
require "./render"
require "./response"
require "http/server"

module Artanis
  class Application
    include DSL
    include Render

    getter :context

    def self.call(context)
      new(context).call
    end

    def initialize(@context : HTTP::Server::Context)
      @params = {} of String => String
      @parsed_body = false
    end

    def request
      context.request
    end

    def params
      parse_body_params
      @params
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

    private def no_such_route
      not_found { "NOT FOUND: #{request.method} #{request.path}" }
    end

    private def parse_body_params
      return if @parsed_body
      @parsed_body = true
      return unless request.headers["Content-Type"]? == "application/x-www-form-urlencoded"
      if body = request.body
        HTTP::Params.parse(body.gets_to_end) { |key, value| @params[key] = value }
      end
    end

    macro inherited
      views_path "views"
    end
  end
end
