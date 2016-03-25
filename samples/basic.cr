require "../src/artanis"
require "http/server"

class App < Artanis::Application
  get "/" do
    "ROOT"
  end

  get "/posts" do
    "POSTS"
  end

  get "/posts/:id.json" do
    "POST: #{params["id"]}"
  end

  delete "/blog/:name/posts/:post_id/comments/:id.:format" do |name, post_id, id, format|
    "COMMENT: #{params.inspect} #{[name, post_id, id, format]}"
  end

  get "/wiki/*path" do |path|
    "WIKI: #{path}"
  end

  get "/kiwi/*path.:format" do |path, format|
    "KIWI: #{path} (#{format})"
  end

  get "/optional(.:format)" do |format|
    "OPTIONAL (#{format})"
  end
end

def call(method, path)
  request = HTTP::Request.new(method, path)
  response = HTTP::Server::Response.new(200)
  context = HTTP::Server::Context.new(request, response)
  App.call(context)
end

puts "ASSERTIONS:"
puts call("GET", "/").body
puts call("GET", "/posts").body
puts call("GET", "/posts/1.json").body
puts call("DELETE", "/blog/me/posts/123/comments/456.xml").body
puts call("GET", "/wiki/category/page.html").body
puts call("GET", "/kiwi/category/page.html").body
puts call("GET", "/optional").body
puts call("GET", "/optional.html").body
puts

puts "REFUTATIONS:"
puts call("GET", "/fail").body
puts call("GET", "/posts/1").body
puts call("DELETE", "/blog/me/posts/123/comments/456").body
puts
