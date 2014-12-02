module Rack
  class StripCookies
    attr_reader :paths

    def initialize(app, options = {})
      @app, @paths = app, Array(options[:paths])
    end

    def call(env)
      path     = Rack::Request.new(env).path
      included = paths.any? { |s| s.include?(path)}

      env.delete('HTTP_COOKIE') if included

      status, headers, body = @app.call(env)
      headers.delete('Set-Cookie') if included

      [status, headers, body]
    end
  end
end
