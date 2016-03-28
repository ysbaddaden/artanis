require "http/server"
require "../src/artanis"

class App < Artanis::Application

  views_path "#{ __DIR__ }/views"  
 
  
  head "/" do
   "Head request"
  end

  get "/" do
    @message = "message: index"
  end
  
  before do
    logfilename = "logging.log"
    setlogfile
    response.headers.add("Content-Type", "text/html;charset=utf-8")
    response.headers.add("X-XSS-Protection", "1; mode=block")
    response.headers.add("X-Content-Type-Options", "nosniff")
    response.headers.add("X-Frame-Options", "SAMEORIGIN")
  end

  get "/sdf" do
    ecr "index", "index"
  end
  
  get "/filters" do
    response.body = "Hello"
  end

  after do
    logging true
  end

end

server = HTTP::Server.new(9292) do |context|
  App.call(context)
end

puts "Listening on http://0.0.0.0:9292"
server.listen
