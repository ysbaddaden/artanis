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

    $ wrk -c 1000 -d 60 -t 1 http://localhost:9292/
    Running 1m test @ http://localhost:9292/
      1 threads and 1000 connections
      Thread Stats   Avg      Stdev     Max   +/- Stdev
        Latency    15.42ms    3.06ms 217.73ms   90.38%
        Req/Sec    65.05k     5.13k   71.49k    90.67%
      3883581 requests in 1.00m, 344.44MB read
    Requests/sec:  64693.76
    Transfer/sec:      5.74MB

NOTE: trying to use many wrk threads will cut the number of requests in half for
each new thread. I suppose this is due to HTTP::Server and coroutines being
single threaded for now (?)

A better benchmark is available in `test/dsl_bench.cr` which monitors some
limits of the generated Crystal code, like going over all routes to find nothing
takes an awful lot of time, since it must build/execute a regular expression
against EVERY routes to eventually... find nothing.

    $ crystal run --release test/dsl_bench.cr
    get root: 0.82 µs
    get param: 2.36 µs
    get params (block args): 3.34 µs
    get many params: 6.16 µs
    get many params (block args): 4.58 µs
    not found (method): 0.75 µs
    not found (path): 19.14 µs

Keep in mind these numbers tell nothing about reality. They only measure how
fast the generated `Application.call(request)` method is in predefined cases.

## License

Licensed under the MIT License
