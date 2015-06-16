require "http/server"
require "../src/artanis"

class App < Artanis::Application
  get "/" do
    "ROOT"
  end

  get "/posts" do
    "here are some posts"
  end

  get "/posts/:id.:format" do
    p params["id"]
    p params["format"]
    "OK"
  end

  get "/posts/:post_id/comments/:id(.:format)" do |post_id, id, format|
    p params["format"]?
    200
  end
end

server = HTTP::Server.new(9292) do |request|
  App.call(request)
end

puts "Listening on http://0.0.0.0:9292"
server.listen
