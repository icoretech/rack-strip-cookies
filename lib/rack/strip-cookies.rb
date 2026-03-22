# lib/rack/strip-cookies.rb
module Rack
  class StripCookies
    attr_reader :app, :patterns, :invert, :expose_header

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
      @expose_header = options.fetch(:expose_header, false)
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
      # Non-wildcard paths match both the exact path and any descendant path.
      # Wildcard paths only match descendant paths.
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

        # Remove any case variant of the 'Set-Cookie' header from the response headers.
        headers.keys.each do |header_name|
          headers.delete(header_name) if header_name.to_s.casecmp?("set-cookie")
        end

        # Expose the stripping decision only when explicitly enabled.
        headers["cookies-stripped"] = "true" if expose_header
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
        elsif path == "/"
          # Root path matches every Rack path.
          %r{\A/.*\z}
        else
          # Base path pattern: "/api" -> matches "/api" and "/api/anything"
          Regexp.new("^#{Regexp.escape(path)}(?:$|/.*)")
        end
      end
    end
  end
end
