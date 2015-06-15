module Artanis
  class Request
    getter :method, :path

    def initialize(@method, @path)
    end
  end
end