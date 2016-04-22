require "http/server"
require "../src/artanis"

class App < Artanis::Application

  views_path "#{ __DIR__ }/views"  
 
  before do
    logfilename = "logging.log"
    setlogfile
    response.headers.add("Content-Type", "text/html;charset=utf-8")
    response.headers.add("X-XSS-Protection", "1; mode=block")
    response.headers.add("X-Content-Type-Options", "nosniff")
    response.headers.add("X-Frame-Options", "SAMEORIGIN")
  end

  head "/" do
   "Head request"
  end

  get "/" do
    "Index"
  end

  get "/sample" do
    "Sample Page"
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
