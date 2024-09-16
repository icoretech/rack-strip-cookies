# lib/rack/strip-cookies.rb
module Rack
  class StripCookies
    attr_reader :app, :paths, :invert

    # Initializes the middleware.
    #
    # @param app [Rack application] The Rack application.
    # @param options [Hash] The options to customize the middleware behavior.
    # @option options [Array<String>] :paths The paths where cookies should be deleted.
    # @option options [Boolean] :invert Whether to invert the paths where cookies are deleted.
    def initialize(app, options = {})
      @app = app
      @paths = Array(options[:paths])
      @invert = options[:invert] || false
    end

    # Entry point of the middleware.
    #
    # @param env [Hash] The request environment.
    # @return [Array] The response containing the status, headers, and body.
    def call(env)
      # Extract the path from the request
      path = Rack::Request.new(env).path

      # Check if the request path is in the list of paths to be stripped
      included = paths.any? { |s| path.include?(s) }

      # Decide whether to strip cookies based on the request path and the invert flag
      strip_out = (included && !invert) || (!included && invert)

      # If cookies are to be stripped, delete the HTTP_COOKIE from the request environment
      env.delete("HTTP_COOKIE".freeze) if strip_out

      # Call the next middleware/app and get the status, headers, and body of the response
      status, headers, body = @app.call(env)

      # If cookies are to be stripped, delete the Set-Cookie header from the response
      headers.delete("set-cookie".freeze) if strip_out

      # If cookies were stripped, insert a custom header indicating that fact
      headers["cookies-stripped".freeze] = "true" if strip_out

      # Return the response (status, headers, body) to the next middleware or the web server
      [status, headers, body]
    end
  end
end
