# Artanis

Crystal's metaprogramming macros to build a Sinatra-like DSL for the Crystal
language.

## Rationale

The DSL doesn't stock blocks to be invoked later on, but rather produces actual
methods using macros (`match` and the sugar `get`, `post`, etc.) where special
chars like `/`, `.`, `(` and `)` are replaced as `_SLASH_`, `_DOT_`, `_LPAREN_`
and `_RPAREN_`. Also, `:param` segments are replaced to `_PARAM_`.

Eventually methods look like:

    get "/posts"        |    def match_GET__SLASH_posts
    get "/posts.xml"    |    def match_GET__SLASH_posts_DOT_xml

Please read [dsl.cr](https://github.com/ysbaddaden/artanis/tree/master/src/dsl.cr)
for more details.

Eventually a call method is generated. It iterates over the class methods,
selects the generated `match_*` methods and generates a big `case` statement,
transforming the method names back to regular expressions, and eventually
calling the method with matched data (if any).

Please read [application.cr](https://github.com/ysbaddaden/artanis/tree/master/src/application.cr)
for more details.

## Usage

```crystal
require "http/server"
require "./src/artanis"

class App < Artanis::Application
  get "/" do
    "ROOT"
  end

  get "/forbidden" do
    403
  end

  get "/posts/:id.:format" do
    p params["id"]
    p params["format"]
    "post"
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
```

## Benchmark

Running wrk against the above example (pointless hello world) gives the following
results (TL;DR 15µs per request):

```
$ wrk -c 1000 -t 1 -d 30 http://localhost:9292/
Running 30s test @ http://localhost:9292/
  1 threads and 1000 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    14.56ms    3.69ms 219.83ms   96.04%
    Req/Sec    68.74k     3.78k   72.97k    94.00%
  2052623 requests in 30.02s, 129.20MB read
Requests/sec:  68373.45
Transfer/sec:      4.30MB
```

A better benchmark is available in `test/dsl_bench.cr` which monitors some
limits of the generated Crystal code, like going over all routes to find nothing
takes an awful lot of time, since it must build/execute a regular expression
against EVERY routes to eventually... find nothing.

```
$ crystal run --release test/dsl_bench.cr
get root: 1.49 µs
get param: 2.34 µs
get params (block args): 3.24 µs
get many params: 6.34 µs
get many params (block args): 5.24 µs
not found (method): 1.84 µs
not found (path): 18.48 µs
```

Keep in mind these numbers tell nothing about reality. They only measure how
fast the generated `Application.call(request)` method is in predefined cases.

## License

Licensed under the MIT License
