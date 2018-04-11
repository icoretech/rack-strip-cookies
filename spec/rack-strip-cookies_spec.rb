require 'rubygems'
require 'minitest/autorun'
require 'rack/mock'
require 'rack/test'
require 'coveralls'

require_relative '../lib/rack/strip-cookies'

Coveralls.wear!

describe Rack::StripCookies do
  include Rack::Test::Methods

  def app; Rack::Lint.new(@app); end

  def mock_app(options_or_options_array = {})
    main_app = lambda { |env|
      _request = Rack::Request.new(env)
      headers = {'Content-Type' => "text/html"}
      headers['Set-Cookie'] = "id=1; path=/oauth/token; secure; HttpOnly"
      [200, headers, ['Hello there']]
    }

    builder = Rack::Builder.new
    options_or_options_array = [options_or_options_array] unless options_or_options_array.is_a?(Array)
    Array(options_or_options_array).each do |options|
      builder.use Rack::StripCookies, options
    end
    builder.run main_app
    @app = builder.to_app
  end

  it 'does not clean the cookie on another path' do
    mock_app(paths: ["/oauth/token"])

    get 'http://www.example.org/oauth'
    assert_equal last_response.headers['Set-Cookie'].split("\n"), ["id=1; path=/oauth/token; secure; HttpOnly"], "cookie is present"
  end

  it 'clean the cookie' do
    mock_app(paths: ["/oauth/token"])

    get 'http://www.example.org/oauth/token'
    assert_nil last_response.headers['Set-Cookie'], "cookie is missing"
  end

  it 'clean the cookie on all other paths' do
    mock_app(paths: ["/oauth/token"], invert: true)

    get "http://www.example.org/outh#{rand(10)}"
    assert_nil last_response.headers['Set-Cookie'], "cookie is missing"
  end

  it 'dont clean the cookie on given path' do
    mock_app(paths: ["/oauth/token"], invert: true)

    get 'http://www.example.org/oauth/token'
    assert_equal last_response.headers['Set-Cookie'].split("\n"), ["id=1; path=/oauth/token; secure; HttpOnly"], "cookie is present"
  end
end
