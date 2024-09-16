# lib/rack/strip-cookies.rb
module Rack
  class StripCookies
    attr_reader :app, :patterns, :invert

    # Initializes the middleware.
    #
    # @param app [Rack application] The Rack application.
    # @param options [Hash] The options to customize the middleware behavior.
    # @option options [Array<String>] :paths The paths or patterns where cookies should be deleted.
    #   - Exact paths: "/api"
    #   - Wildcard paths: "/api/*"
    # @option options [Boolean] :invert Whether to invert the paths where cookies are deleted.
    def initialize(app, options = {})
      @app = app
      @invert = options.fetch(:invert, false)
      @patterns = compile_patterns(options[:paths] || [])
    end

    # Entry point of the middleware.
    #
    # This method is called for each HTTP request that passes through the middleware.
    # It determines whether to strip cookies from the request and response based on
    # the configured paths/patterns and the invert flag.
    #
    # @param env [Hash] The request environment.
    # @return [Array] The response containing the status, headers, and body.
    def call(env)
      # Extract the request path from the environment.
      # 'PATH_INFO' contains the path portion of the URL, e.g., "/dashboard".
      path = env["PATH_INFO"] || "/"

      # Determine if the current path matches any of the compiled patterns.
      # Each pattern is a regex that represents either an exact match or a wildcard match.
      matched = patterns.any? { |regex| regex.match?(path) }

      # Decide whether to strip cookies based on the matching result and the invert flag.
      # If 'invert' is false:
      #   - Cookies are stripped if the path matches any of the specified patterns.
      # If 'invert' is true:
      #   - Cookies are stripped if the path does NOT match any of the specified patterns.
      strip_out = (matched && !invert) || (!matched && invert)

      if strip_out
        # Remove the 'HTTP_COOKIE' header from the request environment.
        # This prevents any cookies from being sent to the application.
        env.delete("HTTP_COOKIE")

        # Call the next middleware or application in the stack with the modified environment.
        # This returns the HTTP status, headers, and body of the response.
        status, headers, body = @app.call(env)

        # Remove the 'Set-Cookie' header from the response headers.
        headers.delete("set-cookie")

        # Add a custom header 'Cookies-Stripped' to indicate that cookies were stripped.
        headers["cookies-stripped"] = "true"
      else
        # If cookies are not to be stripped, simply call the next middleware or application.
        # The original request and response headers remain untouched.
        status, headers, body = @app.call(env)
      end

      # Return the final response to the client.
      # The response is an array containing the status code, headers hash, and body array.
      [status, headers, body]
    end

    private

    # Compiles the user-specified paths/patterns into regular expressions.
    #
    # @param paths [Array<String>] The paths or patterns to compile.
    # @return [Array<Regexp>] The array of compiled regular expressions.
    def compile_patterns(paths)
      paths.map do |path|
        if path.end_with?("/*")
          # Wildcard pattern: "/api/*" -> matches "/api/" and "/api/anything"
          prefix = Regexp.escape(path.chomp("/*"))
          Regexp.new("^#{prefix}/.*$")
        else
          # Exact match pattern: "/api" -> matches only "/api"
          Regexp.new("^#{Regexp.escape(path)}$")
        end
      end
    end
  end
end
