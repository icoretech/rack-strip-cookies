# Rack::StripCookies

Rack::StripCookies is a straightforward Rack middleware that deletes cookies at designated paths.

## Getting Started

### Installation

To include this gem in your project, add the following line to your Gemfile:

```ruby
gem 'rack-strip-cookies', '~> 1.0.0'
```

Then, run the bundle command:

```sh
bundle
```

## Overview

The primary aim of this gem is to not only prevent a client from receiving a cookie through the `Set-Cookie` header, but also to eliminate cookies sent in the request.
Consequently, provided the middleware is correctly positioned in the stack, any cookies sent by the client will not reach your application layer.

## Usage Scenarios

- If a third-party library in your application is defective and throws an exception when cookies are present in a request (e.g., an authentication engine), this gem can be helpful.
- This gem provides a simple solution if you need to disable session cookies in your framework.
- It allows you to selectively disable cookies on specific paths, which can be configured when integrating the middleware.

## Integration with Ruby on Rails

If you want to make this middleware available across all environments, open `config/application.rb` and add the following line in `class Application < Rails::Application`:

```ruby
config.middleware.insert_before(ActionDispatch::Cookies, Rack::StripCookies, paths: %w(/oauth2/token))
```

If you wish to enable the middleware only in certain environments, modify the corresponding environment files.

To confirm the middleware's position, run the `rake middleware` command in the root directory of your application.

## How to Contribute

We welcome contributions to improve this project. Here's how you can participate:

1. Fork this repository.
2. Create a new feature branch on your local copy (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push your branch to your forked repository (`git push origin my-new-feature`).
5. Open a new Pull Request on this repository for us to review and merge your changes.
