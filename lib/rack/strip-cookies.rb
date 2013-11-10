module Rack
  class StripCookies
    def initialize(app, options = {})
      default_options = {
        paths: []
      }
      @app, @options = app, default_options.merge(options)
    end

    def call(env)
      if @options[:paths].include?(Rack::Request.new(env).path)
        env.delete('HTTP_COOKIE')
      end
      @app.call(env)

      env.delete('HTTP_COOKIE')
    end
  end
