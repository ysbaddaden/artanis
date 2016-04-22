require "../src/artanis"
require "../src/logging"

class LogApp < Artanis::Application
  include Artanis::Logging

  before do
    info "lorem ipsum"
  end

  get "/" do
    warn "ERR"
    "ERR\n"
  end
end

server = HTTP::Server.new(9292) do |context|
  LogApp.call(context)
end
server.listen
