module Rack
  class StripCookies
    attr_reader :paths

    def initialize(app, options = {})
      @app, @paths = app, Array(options[:paths])
    end

    def call(env)
      path = Rack::Request.new(env).path
      env.delete('HTTP_COOKIE') if paths.include?(path)
      status, headers, body = @app.call(env)
      headers.delete('Set-Cookie') if paths.include?(path)
      # request.session_options[:skip] = true
      # env.delete('HTTP_COOKIE')
    end

    [status, headers, body]
  end
end
