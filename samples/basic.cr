require "./artanis"

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

puts "ASSERTIONS:"
puts App.call(HTTP::Request.new("GET", "/")).body
puts App.call(HTTP::Request.new("GET", "/posts")).body
puts App.call(HTTP::Request.new("GET", "/posts/1.json")).body
puts App.call(HTTP::Request.new("DELETE", "/blog/me/posts/123/comments/456.xml")).body
puts App.call(HTTP::Request.new("GET", "/wiki/category/page.html")).body
puts App.call(HTTP::Request.new("GET", "/kiwi/category/page.html")).body
puts App.call(HTTP::Request.new("GET", "/optional")).body
puts App.call(HTTP::Request.new("GET", "/optional.html")).body

puts
puts "REFUTATIONS:"
puts App.call(HTTP::Request.new("GET", "/fail")).body
puts App.call(HTTP::Request.new("GET", "/posts/1")).body
puts App.call(HTTP::Request.new("DELETE", "/blog/me/posts/123/comments/456")).body

