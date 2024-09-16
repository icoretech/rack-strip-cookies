# spec/rack-strip-cookies_spec.rb
require "rubygems"
require "minitest/autorun"
require "rack/mock"
require "rack/test"
require "rack/builder"
require "rack/lint"

require_relative "../lib/rack/strip-cookies"

describe Rack::StripCookies do
  include Rack::Test::Methods

  def app = Rack::Lint.new(@app)

  def mock_app(options_or_options_array = {})
    main_app = lambda { |env|
      request = Rack::Request.new(env)
      headers = {"content-type" => "text/html"}
      headers["set-cookie"] = "id=1; path=#{request.path}; secure; HttpOnly"
      [200, headers, ["Hello there"]]
    }

    builder = Rack::Builder.new
    options_or_options_array = [options_or_options_array] unless options_or_options_array.is_a?(Array)
    Array(options_or_options_array).each do |options|
      builder.use Rack::StripCookies, options
    end
    builder.run main_app
    @app = builder.to_app
  end

  it "does not clean the cookie on another path" do
    mock_app(paths: ["/oauth/token"])

    get "http://www.example.org/oauth"
    _(last_response.headers["set-cookie"]).must_equal "id=1; path=/oauth; secure; HttpOnly"
    _(last_response.headers["cookies-stripped"]).must_be_nil
  end

  it "cleans the cookie" do
    mock_app(paths: ["/oauth/token"])

    get "http://www.example.org/oauth/token"
    _(last_response.headers["set-cookie"]).must_be_nil
    _(last_response.headers["cookies-stripped"]).must_equal "true"
  end

  it "cleans the cookie on all other paths" do
    mock_app(paths: ["/oauth/token"], invert: true)

    get "http://www.example.org/outh#{rand(10)}"
    _(last_response.headers["set-cookie"]).must_be_nil
    _(last_response.headers["cookies-stripped"]).must_equal "true"
  end

  it "doesn't clean the cookie on the given path" do
    mock_app(paths: ["/oauth/token"], invert: true)

    get "http://www.example.org/oauth/token"
    _(last_response.headers["set-cookie"]).must_equal "id=1; path=/oauth/token; secure; HttpOnly"
    _(last_response.headers["cookies-stripped"]).must_be_nil
  end

  it "cleans the cookie when invert is false and path matches exactly" do
    mock_app(paths: ["/oauth/token"], invert: false)

    get "http://www.example.org/oauth/token"
    _(last_response.headers["set-cookie"]).must_be_nil
    _(last_response.headers["cookies-stripped"]).must_equal "true"
  end

  it "does not clean the cookie when paths are empty" do
    mock_app(paths: [])

    get "http://www.example.org/oauth/token"
    _(last_response.headers["set-cookie"]).must_equal "id=1; path=/oauth/token; secure; HttpOnly"
    _(last_response.headers["cookies-stripped"]).must_be_nil
  end

  # New Tests for Wildcard Pattern Matching
  describe "Wildcard Path Matching" do
    it "cleans the cookie for a subpath matching a wildcard pattern" do
      mock_app(paths: ["/api/*"])

      get "http://www.example.org/api/test1"
      _(last_response.headers["set-cookie"]).must_be_nil
      _(last_response.headers["cookies-stripped"]).must_equal "true"
    end

    it "does not clean the cookie for the exact path when a wildcard pattern is specified" do
      mock_app(paths: ["/api/*"])

      get "http://www.example.org/api"
      _(last_response.headers["set-cookie"]).must_equal "id=1; path=/api; secure; HttpOnly"
      _(last_response.headers["cookies-stripped"]).must_be_nil
    end

    it "cleans cookies for multiple wildcard patterns" do
      mock_app(paths: ["/api/*", "/admin/*"])

      get "http://www.example.org/api/v1/users"
      _(last_response.headers["set-cookie"]).must_be_nil
      _(last_response.headers["cookies-stripped"]).must_equal "true"

      get "http://www.example.org/admin/settings"
      _(last_response.headers["set-cookie"]).must_be_nil
      _(last_response.headers["cookies-stripped"]).must_equal "true"
    end

    it "does not clean cookies for paths not matching any wildcard patterns" do
      mock_app(paths: ["/api/*", "/admin/*"])

      get "http://www.example.org/home"
      _(last_response.headers["set-cookie"]).must_equal "id=1; path=/home; secure; HttpOnly"
      _(last_response.headers["cookies-stripped"]).must_be_nil
    end

    it "cleans the cookie for subpaths when both exact and wildcard patterns are provided" do
      mock_app(paths: ["/api", "/admin/*"])

      # Exact path "/api" should strip cookies
      get "http://www.example.org/api"
      _(last_response.headers["set-cookie"]).must_be_nil
      _(last_response.headers["cookies-stripped"]).must_equal "true"

      # Subpath "/admin/settings" should strip cookies
      get "http://www.example.org/admin/settings"
      _(last_response.headers["set-cookie"]).must_be_nil
      _(last_response.headers["cookies-stripped"]).must_equal "true"

      # Path "/api/v1" should not strip cookies (no wildcard for "/api/*")
      get "http://www.example.org/api/v1"
      _(last_response.headers["set-cookie"]).must_equal "id=1; path=/api/v1; secure; HttpOnly"
      _(last_response.headers["cookies-stripped"]).must_be_nil
    end

    it "cleans cookies for wildcard patterns with invert: false" do
      mock_app(paths: ["/public/*"], invert: false)

      get "http://www.example.org/public/images"
      _(last_response.headers["set-cookie"]).must_be_nil
      _(last_response.headers["cookies-stripped"]).must_equal "true"
    end

    it "does not clean cookies for wildcard patterns with invert: true" do
      mock_app(paths: ["/public/*"], invert: true)

      get "http://www.example.org/public/images"
      _(last_response.headers["set-cookie"]).must_equal "id=1; path=/public/images; secure; HttpOnly"
      _(last_response.headers["cookies-stripped"]).must_be_nil
    end

    it "strips cookies for nested wildcard patterns" do
      mock_app(paths: ["/api/*", "/api/v1/*"])

      get "http://www.example.org/api/v1/users"
      _(last_response.headers["set-cookie"]).must_be_nil
      _(last_response.headers["cookies-stripped"]).must_equal "true"

      get "http://www.example.org/api/v2/orders"
      _(last_response.headers["set-cookie"]).must_be_nil
      _(last_response.headers["cookies-stripped"]).must_equal "true"
    end

    it "handles paths with trailing slashes correctly" do
      mock_app(paths: ["/api/*"])

      get "http://www.example.org/api/v1/"
      _(last_response.headers["set-cookie"]).must_be_nil
      _(last_response.headers["cookies-stripped"]).must_equal "true"

      get "http://www.example.org/api/"
      _(last_response.headers["set-cookie"]).must_be_nil
      _(last_response.headers["cookies-stripped"]).must_equal "true"
    end

    it "handles paths with query parameters correctly" do
      mock_app(paths: ["/api/*"])

      get "http://www.example.org/api/v1/users?active=true"
      _(last_response.headers["set-cookie"]).must_be_nil
      _(last_response.headers["cookies-stripped"]).must_equal "true"

      get "http://www.example.org/api?user=1"
      _(last_response.headers["set-cookie"]).must_equal "id=1; path=/api; secure; HttpOnly"
      _(last_response.headers["cookies-stripped"]).must_be_nil
    end

    it "does not strip cookies for paths matching only part of the pattern" do
      mock_app(paths: ["/api/*"])

      get "http://www.example.org/application/api/test"
      _(last_response.headers["set-cookie"]).must_equal "id=1; path=/application/api/test; secure; HttpOnly"
      _(last_response.headers["cookies-stripped"]).must_be_nil
    end
  end

  describe "Combination of Exact and Wildcard Paths with Invert" do
    it "strips cookies for exact path and wildcard subpaths" do
      mock_app(paths: ["/api", "/admin/*"])

      # Exact path "/api" should strip cookies
      get "http://www.example.org/api"
      _(last_response.headers["set-cookie"]).must_be_nil
      _(last_response.headers["cookies-stripped"]).must_equal "true"

      # Subpath "/admin/settings" should strip cookies
      get "http://www.example.org/admin/settings"
      _(last_response.headers["set-cookie"]).must_be_nil
      _(last_response.headers["cookies-stripped"]).must_equal "true"

      # Path "/admin" should not strip cookies
      get "http://www.example.org/admin"
      _(last_response.headers["set-cookie"]).must_equal "id=1; path=/admin; secure; HttpOnly"
      _(last_response.headers["cookies-stripped"]).must_be_nil
    end

    it "strips cookies based on wildcard patterns with invert: true" do
      mock_app(paths: ["/public/*", "/docs/*"], invert: true)

      # Paths not matching "/public/*" or "/docs/*" should strip cookies
      get "http://www.example.org/home"
      _(last_response.headers["set-cookie"]).must_be_nil
      _(last_response.headers["cookies-stripped"]).must_equal "true"

      get "http://www.example.org/contact"
      _(last_response.headers["set-cookie"]).must_be_nil
      _(last_response.headers["cookies-stripped"]).must_equal "true"

      # Paths matching "/public/*" should not strip cookies
      get "http://www.example.org/public/images"
      _(last_response.headers["set-cookie"]).must_equal "id=1; path=/public/images; secure; HttpOnly"
      _(last_response.headers["cookies-stripped"]).must_be_nil

      # Paths matching "/docs/*" should not strip cookies
      get "http://www.example.org/docs/getting-started"
      _(last_response.headers["set-cookie"]).must_equal "id=1; path=/docs/getting-started; secure; HttpOnly"
      _(last_response.headers["cookies-stripped"]).must_be_nil
    end
  end
end
