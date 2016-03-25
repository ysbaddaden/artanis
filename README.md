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
require "artanis"

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

server = HTTP::Server.new(9292) do |context|
  App.call(context)
end

puts "Listening on http://0.0.0.0:9292"
server.listen
```

## Benchmark

Running wrk against the above example (pointless hello world) gives the following
results (TL;DR 12µs per request):

```
$ wrk -c 1000 -t 2 -d 5 http://localhost:9292/fast
Running 5s test @ http://localhost:9292/fast
  2 threads and 1000 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    12.26ms   14.48ms 423.28ms   99.05%
    Req/Sec    41.17k     2.93k   48.65k    76.00%
  409663 requests in 5.01s, 25.79MB read
Requests/sec:  81722.08
Transfer/sec:      5.14MB
```

A better benchmark is available in `test/dsl_bench.cr` which monitors some
limits of the generated Crystal code, like going over all routes to find nothing
takes an awful lot of time, since it must build/execute a regular expression
against EVERY routes to eventually... find nothing.

```
$ crystal run --release test/dsl_bench.cr
get root: 0.84 µs
get param: 1.51 µs
get params (block args): 2.18 µs
get many params: 3.75 µs
get many params (block args): 2.59 µs
not found (method): 0.73 µs
not found (path): 15.93 µs
```

Keep in mind these numbers tell nothing about reality. They only measure how
fast the generated `Application.call(request)` method is in predefined cases.

## License

Licensed under the MIT License
