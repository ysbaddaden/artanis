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
puts App.call(Artanis::Request.new("GET", "/"))
puts App.call(Artanis::Request.new("GET", "/posts"))
puts App.call(Artanis::Request.new("GET", "/posts/1.json"))
puts App.call(Artanis::Request.new("DELETE", "/blog/me/posts/123/comments/456.xml"))
puts App.call(Artanis::Request.new("GET", "/wiki/category/page.html"))
puts App.call(Artanis::Request.new("GET", "/kiwi/category/page.html"))
puts App.call(Artanis::Request.new("GET", "/optional"))
puts App.call(Artanis::Request.new("GET", "/optional.html"))

puts
puts "REFUTATIONS:"
puts App.call(Artanis::Request.new("GET", "/fail"))
puts App.call(Artanis::Request.new("GET", "/posts/1"))
puts App.call(Artanis::Request.new("DELETE", "/blog/me/posts/123/comments/456"))

