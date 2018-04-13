module Rack
  class StripCookies
    attr_reader :paths
    attr_reader :invert

    def initialize(app, options = {invert: false})
      @app, @paths, @invert = app, Array(options[:paths]), options[:invert] == true
    end

    def call(env)
      path     = Rack::Request.new(env).path
      included = paths.any? { |s| path.include?(s)}

      # Strip cookies from all requests
      # 1) that are mentioned in paths and invert is false. or
      # 2) that are not mentioned in paths and invert is true.
      strip_out = ((included && !invert) || (!included && invert))

      env.delete('HTTP_COOKIE') if strip_out

      status, headers, body = @app.call(env)
      headers.delete('Set-Cookie') if strip_out

      # insert a header if cookies where stripped for the request.
      headers = headers.merge("Cookies-Stripped" => "true") if strip_out
      [status, headers, body]
    end
  end
end
