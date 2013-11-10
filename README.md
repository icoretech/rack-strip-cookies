# Rack::StripCookies [![Build Status](https://secure.travis-ci.org/icoretech/rack-strip-cookies.png)](https://travis-ci.org/icoretech/rack-strip-cookies?branch=master)

Simple Rack middleware to remove cookies at specified paths.

## Installation

Add this line to your application's Gemfile:

    gem 'rack-strip-cookies'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-strip-cookies

## Concept

The goal of this gem is not only avoid serving a cookie to a client through the Set-Cookie header, but also to erase cookies sent in the request. In other words the client-sent cookies will not make it to your application layer, provided the middleware is loaded in the correct place in the stack.

## Use cases

- You have a buggy third party library that raises exception when cookies are sent in a request, such as an authentication engine.
- You are looking for a cheap way to not mess with session cookie disabilitation in your framework.
- Selectively shut down cookies on specific paths, configurable when adding the middleware.

## Ruby on Rails

To make the middleware available in all environments, open `config/application.rb` and add in `class Application < Rails::Application`:

```ruby
config.middleware.insert_before(ActionDispatch::Cookies, Rack::StripCookies, paths: %w(/oauth2/token))
```

If you want to customize the environment in which the middleware is enabled edit the respective environment files instead.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
