module Rack
  class StripCookies
    attr_reader :paths

    def initialize(app, options = {})
      @app, @paths = app, Array(options[:paths])
    end

    def call(env)
      if paths.include?(Rack::Request.new(env).path)
        env.delete('HTTP_COOKIE')
      end
      @app.call(env)
    end
  end
end
