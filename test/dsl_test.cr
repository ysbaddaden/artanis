require "./test_helper"

class Artanis::DSLTest < Minitest::Test
  def test_simple_routes
    response = call("GET", "/")
    assert_equal "ROOT", response.body
    assert_equal 200, response.status_code

    assert_equal "POSTS", call("GET", "/posts").body
  end

  def test_simple_status_code
    response = call("POST", "/forbidden")
    assert_equal 403, response.status_code
    assert_empty response.body
  end

  def test_no_such_routes
    response = call("GET", "/fail")
    assert_equal "NOT FOUND: GET /fail", response.body
    assert_equal 404, response.status_code

    response = call("POST", "/")
    assert_equal "NOT FOUND: POST /", response.body
    assert_equal 404, response.status_code

    assert_equal "NOT FOUND: DELETE /posts", call("DELETE", "/posts").body
  end

  def test_routes_with_lowercase_method
    assert_equal "ROOT", call("get", "/").body
  end

  def test_routes_with_unicode_chars
    assert_equal "TELUGU", call("get", "/lang/#{URI.encode_path_segment("తెలుగు")}").body
  end

  def test_routes_with_special_chars
    assert_equal "POST-OFFICE", call("get", "/online-post-office").body
    assert_equal "POST_OFFICE", call("get", "/online_post_office").body
  end

  def test_routes_with_dot_separator
    assert_equal "POSTS (xml)", call("GET", "/posts.xml").body
    assert_equal "NOT FOUND: GET /posts.json", call("GET", "/posts.json").body
  end

  def test_routes_with_params
    assert_equal "POST: 1", call("GET", "/posts/1.json").body
    assert_equal "POST: 456", call("GET", "/posts/456.json").body
    assert_equal "COMMENT: #{ { "name" => "me", "post_id" => "123", "id" => "456", "format" => "xml" }.inspect } #{ ["me", "123", "456", "xml"].inspect }",
      call("DELETE", "/blog/me/posts/123/comments/456.xml").body
  end

  def test_routes_with_splat_params
    assert_equal "WIKI: category/page.html", call("GET", "/wiki/category/page.html").body
    assert_equal "KIWI: category/page (html)", call("GET", "/kiwi/category/page.html").body
  end

  def test_routes_with_optional_segments
    assert_equal "OPTIONAL ()", call("GET", "/optional").body
    assert_equal "OPTIONAL (html)", call("GET", "/optional.html").body
  end

  def test_halt
    response = call("GET", "/halt")
    assert_equal 200, response.status_code
    assert_empty response.body

    response = call("GET", "/halt/gone")
    assert_equal 410, response.status_code
    assert_empty response.body

    response = call("GET", "/halt/message")
    assert_equal 200, response.status_code
    assert_equal "message", response.body

    response = call("GET", "/halt/code/message")
    assert_equal 401, response.status_code
    assert_equal "please sign in", response.body

    response = call("GET", "/halt/args")
    assert_equal 403, response.status_code
  end

  def test_pass
    response = call("GET", "/pass/check")
    assert_equal 401, response.status_code
    assert_equal "PASS NEXT", response.body
  end

  def test_before_filter
    assert_equal "BEFORE=GLOBAL", call("GET", "/").headers["Before-Filter"]
    assert_equal "BEFORE=GLOBAL,FORBIDDEN", call("GET", "/forbidden").headers["Before-Filter"]
  end

  def test_after_filter
    assert_equal "AFTER=GLOBAL", call("GET", "/").headers["After-Filter"]
    assert_equal "AFTER=GLOBAL,HALT", call("GET", "/halt/message").headers["After-Filter"]
  end

  def test_filters_can_access_intance_variables
    assert_equal "before filter, 2", FilterApp.call(context("GET", "/filters")).body
  end

  def test_before_filter_can_halt
    response = FilterApp.call(context("GET", "/filters", headers: HTTP::Headers{
      "halt" => "before"
    }))
    assert_equal 401, response.status_code
    assert_empty response.body
  end

  def test_after_filter_can_halt
    response = FilterApp.call(context("GET", "/filters", headers: HTTP::Headers{
      "halt" => "after"
    }))
    assert_equal 200, response.status_code
    assert_equal "before filter", response.body
  end

  def test_query_params
    assert_equal({ "id" => "123" }, JSON.parse(call("GET", "/params/123").body).as_h)
    assert_equal({ "id" => "123", "q" => "term" }, JSON.parse(call("GET", "/params/123?id=456&q=term").body).as_h)
    assert_equal({ "id" => "123", "bid" => "456" }, JSON.parse(call("GET", "/params/123?bid=456").body).as_h)
  end

  def test_body_params
    response = call "POST", "/params",
      headers: HTTP::Headers{ "Content-Type" => "application/x-www-form-urlencoded" }
    assert_empty JSON.parse(response.body).as_h

    response = call "POST", "/params?id=789&lang=fr",
      headers: HTTP::Headers{ "Content-Type" => "application/x-www-form-urlencoded" },
      body: "q=term&id=123"
    assert_equal({ "id" => "123", "q" => "term", "lang" => "fr" }, JSON.parse(response.body).as_h)
  end

  def test_encoded_body
    response = call "POST", "/params_body?id=789&lang=fr",
      headers: HTTP::Headers{ "Content-Type" => "application/x-www-form-urlencoded" },
      body: "q=term&id=123"
    assert_equal({ "body" => "q=term&id=123", "id" => "789", "lang" => "fr" }, JSON.parse(response.body).as_h)
  end

  private def call(request, method, headers = nil, body = nil)
    App.call(context(request, method, io: nil, headers: headers, body: body))
  end
end
