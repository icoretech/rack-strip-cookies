module Rack
  class StripCookies
    attr_reader :paths

    def initialize(app, options = {})
      @app, @paths = app, Array(options[:paths])
    end

    def call(env)
      path = Rack::Request.new(env).path
      status, headers, body = @app.call(env)

      if paths.include?(path)
        headers.delete('Set-Cookie')
        # request.session_options[:skip] = true
        # env.delete('HTTP_COOKIE')
      end

      [status, headers, body]
    end
  end
end
