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
      _request = Rack::Request.new(env)
      headers = {"content-type" => "text/html"}
      headers["set-cookie"] = "id=1; path=/oauth/token; secure; HttpOnly"
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
    _(last_response.headers["set-cookie"].split("\n")).must_equal ["id=1; path=/oauth/token; secure; HttpOnly"]
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
    _(last_response.headers["set-cookie"].split("\n")).must_equal ["id=1; path=/oauth/token; secure; HttpOnly"]
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
    _(last_response.headers["set-cookie"].split("\n")).must_equal ["id=1; path=/oauth/token; secure; HttpOnly"]
    _(last_response.headers["cookies-stripped"]).must_be_nil
  end
end
