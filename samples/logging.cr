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

server = HTTP::Server.new { |context| LogApp.call(context) }
server.bind_tcp(9292)
server.listen
