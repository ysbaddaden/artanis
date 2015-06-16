require "minitest/autorun"
require "http/request"
require "../src/artanis"

class App < Artanis::Application
  get "/" do
    "ROOT"
  end

  post "/forbidden" do
    403
  end

  get "/posts" do
    "POSTS"
  end

  get "/posts.xml" do
    "POSTS (xml)"
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

  get "/lang/తెలుగు" do
    "TELUGU"
  end

  get "/online-post-office" do
    "POST-OFFICE"
  end

  get "/online_post_office" do
    "POST_OFFICE"
  end

  get "/halt" do
    halt
    "NEVER REACHED"
  end

  get "/halt/gone" do
    halt 410
    "NEVER REACHED"
  end

  get "/halt/message" do
    halt "message"
    "NEVER REACHED"
  end

  get "/halt/code/message" do
    halt 401, "please sign in"
    "NEVER REACHED"
  end
end
