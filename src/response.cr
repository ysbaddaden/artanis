require "http/server/response"

module Artanis
  class Response
    forward_missing_to @original

    def initialize(@original : HTTP::Server::Response)
      @wrote_body = false
    end

    def body
      @body || ""
    end

    def body?
      @body
    end

    def body=(str)
      @body = str
    end

    def write_body
      if (body = @body) && !@wrote_body
        self << body
        @wrote_body = true
      end
    end

    def flush
      write_body
      @original.flush
    end

    def reset
      @body = @wrote_body = nil
      @original.reset
    end

    def close
      flush
      @original.close
    end
  end
end
