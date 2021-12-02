require "minitest/autorun"
require "http/server"
require "../src/artanis"

class Minitest::Test
  def context(method, path, io = nil, headers = nil, body = nil)
    request = HTTP::Request.new(method, path, headers || HTTP::Headers.new, body)
    response = HTTP::Server::Response.new(io || IO::Memory.new)
    HTTP::Server::Context.new(request, response)
  end
end

class FilterApp < Artanis::Application
  property! :count

  before do
    halt 401 if request.headers["halt"]? == "before"
  end

  before "/filters" do
    @message = "before filter"
    @count = 1
  end

  get "/filters" do
    self.count += 1
    @message
  end

  after do
    halt if request.headers["halt"]? == "after"
  end

  after "/filters" do
    response.body += ", #{@count}"
  end
end

class App < Artanis::Application
  before do
    response.headers.add("Before-Filter", "BEFORE=GLOBAL")
  end

  before "/forbidden" do
    response.headers.add("Before-Filter", "FORBIDDEN")
  end

  after do
    response.headers.add("After-Filter", "AFTER=GLOBAL")
  end

  after "/halt/*splat" do
    response.headers.add("After-Filter", "HALT")
  end

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

  get "/halt/:name" do |name|
    halt 403
    "NEVER REACHED"
  end

  get "/pass/check" do
    status 401
    pass
    "NEVER REACHED"
  end

  get "/never_reached_by_skip" do
    "NEVER REACHED BY SKIP"
  end

  get "/pass/*x" do
    "PASS NEXT"
  end

  get "/params/:id" do
    json(params)
  end

  post "/params" do
    json(params)
  end

  post "/params_body" do
    json({"body" => request.body.try &.gets_to_end}.merge(params))
  end
end
