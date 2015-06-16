require "./test_helper"

class Artanis::DSLTest < Minitest::Test
  def test_simple_routes
    assert_equal "NOT FOUND: GET /fail", call("GET", "/fail")

    assert_equal "ROOT", call("GET", "/")
    assert_equal "NOT FOUND: POST /", call("POST", "/")

    assert_equal "POSTS", call("GET", "/posts")
    assert_equal "NOT FOUND: DELETE /posts", call("DELETE", "/posts")
  end

  def test_routes_with_lowercase_method
    assert_equal "ROOT", call("get", "/")
  end

  def test_routes_with_dot_separator
    assert_equal "POSTS (xml)", call("GET", "/posts.xml")
    assert_equal "NOT FOUND: GET /posts.json", call("GET", "/posts.json")
  end

  def test_routes_with_params
    assert_equal "POST: 1", call("GET", "/posts/1.json")
    assert_equal "POST: 456", call("GET", "/posts/456.json")
    assert_equal "COMMENT: #{ { "name" => "me", "post_id" => "123", "id" => "456", "format" => "xml" }.inspect } #{ ["me", "123", "456", "xml"].inspect }",
      call("DELETE", "/blog/me/posts/123/comments/456.xml")
  end

  def test_routes_with_splat_params
    assert_equal "WIKI: category/page.html", call("GET", "/wiki/category/page.html")
    assert_equal "KIWI: category/page (html)", call("GET", "/kiwi/category/page.html")
  end

  def test_routes_with_optional_segments
    assert_equal "OPTIONAL ()", call("GET", "/optional")
    assert_equal "OPTIONAL (html)", call("GET", "/optional.html")
  end

  def call(request, method)
    App.call(Artanis::Request.new(request, method))
  end
end
