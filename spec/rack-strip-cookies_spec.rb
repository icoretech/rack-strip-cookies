require 'rubygems'
require 'minitest/spec'
require 'minitest/autorun'
require 'rack/mock'
require 'rack/test'

require_relative '../lib/rack/strip-cookies'

describe Rack::StripCookies do
  include Rack::Test::Methods

  def app; Rack::Lint.new(@app); end

  def mock_app(options_or_options_array = {})
    main_app = lambda { |env|
      request = Rack::Request.new(env)
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

  before do
    mock_app(paths: ["/oauth/token"])
  end

  it 'does not clean the cookie on another path' do
    get 'http://www.example.org/oauth'
    last_response.headers['Set-Cookie'].split("\n").must_equal(["id=1; path=/oauth/token; secure; HttpOnly"])
  end

  it 'clean the cookie' do
    get 'http://www.example.org/oauth/token'
    last_response.headers['Set-Cookie'].must_equal(nil)
  end
end
