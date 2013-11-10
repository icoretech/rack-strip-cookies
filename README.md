# Rack::StripCookies [![Build Status](https://secure.travis-ci.org/icoretech/rack-strip-cookies.png)](https://travis-ci.org/icoretech/rack-strip-cookies?branch=master)

Simple Rack middleware to remove cookies at specified paths.

## Installation

Add this line to your application's Gemfile:

    gem 'rack-strip-cookies'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-strip-cookies

## Ruby on Rails

This library has been tested on Rails 3.2 and 4.0.

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
