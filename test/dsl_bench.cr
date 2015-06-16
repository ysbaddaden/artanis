require "./test_helper"

N = 10_000

def bench(title)
  start = Time.now
  N.times { yield }
  elapsed = (Time.now - start).to_f
  puts "#{title}: #{(elapsed / N * 1_000_000).round(2)} µs"
end

class BenchApp < Artanis::Application
  get("/") { "ROOT" }
  get("/posts/:id") { "POSTS/ID" }
  get("/comments/:id") { |id| "COMMENTS/ID" }
  get("/blog/:name/posts/:post_id/comments/:id") { "BLOG/POST/COMMENT" }
  delete("/blog/:name/posts/:post_id/comments/:id") { |name, post_id, id| "DELETE COMMENT" }

  {% for i in 1 .. 100 %}
    get("/posts/{{ i }}") { "" }
    post("/posts/{{ i }}") { "" }
    put("/posts/{{ i }}") { "" }
    patch("/posts/{{ i }}") { "" }
    delete("/posts/{{ i }}") { "" }
  {% end %}
end

method_not_found = Artanis::Request.new("UNKNOWN", "/fail")
path_not_found = Artanis::Request.new("GET", "/fail")
get_root = Artanis::Request.new("GET", "/")
get_post = Artanis::Request.new("GET", "/posts/123")
get_comment = Artanis::Request.new("GET", "/comments/456")
get_post_comment = Artanis::Request.new("GET", "/blog/me/posts/123/comments/456")
delete_comment = Artanis::Request.new("DELETE", "/blog/me/posts/123/comments/456")

#puts BenchApp.call(get_root)
#puts BenchApp.call(get_post)
#puts BenchApp.call(get_comment)
#puts BenchApp.call(get_post_comment)
#puts BenchApp.call(delete_comment)
#puts BenchApp.call(not_found)

bench("get root") { BenchApp.call(get_root) }
bench("get param") { BenchApp.call(get_post) }
bench("get params (block args)") { BenchApp.call(get_comment) }
bench("get many params") { BenchApp.call(get_post_comment) }
bench("get many params (block args)") { BenchApp.call(delete_comment) }
bench("not found (method)") { BenchApp.call(method_not_found) }
bench("not found (path)") { BenchApp.call(path_not_found) }
