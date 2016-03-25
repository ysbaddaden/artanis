require "http/server"
require "../src/artanis"

class App < Artanis::Application
  get "/" do
    "ROOT"
  end

  get "/fast" do
    response << "FAST"
    nil
  end

  get "/posts/:post_id/comments/:id(.:format)" do |post_id, id, format|
    p params
    200
  end
end

server = HTTP::Server.new(9292) do |context|
  App.call(context)
end

puts "Listening on http://0.0.0.0:9292"
server.listen
