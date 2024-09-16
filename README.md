# Rack::StripCookies

Rack::StripCookies is a straightforward Rack middleware that deletes cookies at designated paths, including support for wildcard patterns. This allows for flexible and selective cookie management across various parts of your application.

[![Gem Version](https://badge.fury.io/rb/rack-strip-cookies.svg)](https://badge.fury.io/rb/rack-strip-cookies)
![Git Tag](http://img.shields.io/github/tag/icoretech/rack-strip-cookies.svg)
![Licence](http://img.shields.io/badge/license-MIT-brightgreen.svg)
[![Build Status](https://github.com/icoretech/rack-strip-cookies/actions/workflows/release.yml/badge.svg)](https://github.com/icoretech/rack-strip-cookies/actions/workflows/release.yml)

## Table of Contents

- [Getting Started](#getting-started)
  - [Installation](#installation)
- [Overview](#overview)
- [Usage Scenarios](#usage-scenarios)
- [Usage Examples](#usage-examples)
  - [Using with Rack Alone](#using-with-rack-alone)
  - [Integrating with Ruby on Rails](#integrating-with-ruby-on-rails)
  - [Using with Sinatra](#using-with-sinatra)
  - [Using with Padrino](#using-with-padrino)
  - [Advanced Configuration Options](#advanced-configuration-options)
    - [Wildcard Path Patterns](#wildcard-path-patterns)
    - [Inverting Path Matching](#inverting-path-matching)
    - [Multiple Paths](#multiple-paths)
  - [Combining with Other Middleware](#combining-with-other-middleware)
- [Running Tests Locally](#running-tests-locally)
- [How to Contribute](#how-to-contribute)
- [License](#license)
- [Contact](#contact)

## Getting Started

### Installation

To include this gem in your project, add the following line to your `Gemfile`:

```ruby
gem 'rack-strip-cookies', '~> 2.0.0'
```

Then, run the bundle command:

```sh
bundle install
```

## Overview

The primary aim of this gem is to not only prevent a client from receiving a cookie through the `Set-Cookie` header but also to eliminate cookies sent in the request. Consequently, provided the middleware is correctly positioned in the stack, any cookies sent by the client will not reach your application layer.

## Usage Scenarios

- **Defective Third-Party Libraries**: If a third-party library in your application is defective and throws an exception when cookies are present in a request (e.g., an authentication engine), this gem can be helpful.
- **Disable Session Cookies**: Provides a simple solution if you need to disable session cookies in your framework.
- **Selective Cookie Management**: Allows you to selectively disable cookies on specific paths or patterns, which can be configured when integrating the middleware.

## Usage Examples

### Using with Rack Alone

If you're building a Rack-based application without any specific framework, integrating `Rack::StripCookies` is straightforward.

```ruby
# config.ru
require 'rack'
require 'rack/strip-cookies'

# Define your main application
app = Proc.new do |env|
  headers = { "Content-Type" => "text/html" }
  headers["Set-Cookie"] = "user_id=12345; path=/dashboard; HttpOnly"
  [200, headers, ["Welcome to the Dashboard"]]
end

# Use the StripCookies middleware
use Rack::StripCookies, paths: ['/dashboard']

run app
```

**Explanation:**

- The middleware is configured to strip cookies for the `/dashboard` path.
- When a request is made to `/dashboard`, cookies will be stripped from both the request and response.

### Integrating with Ruby on Rails

To integrate `Rack::StripCookies` into a Ruby on Rails application, follow these steps:

1. **Add the Middleware**

   Open `config/application.rb` and add the middleware to the stack:

   ```ruby
   # config/application.rb
   module YourApp
     class Application < Rails::Application
       # Insert Rack::StripCookies before ActionDispatch::Cookies
       config.middleware.insert_before(ActionDispatch::Cookies, Rack::StripCookies, paths: ['/oauth2/token'])
     end
   end
   ```

2. **Configure in Specific Environments (Optional)**

   If you want to enable the middleware only in certain environments (e.g., production), modify the corresponding environment file:

   ```ruby
   # config/environments/production.rb
   Rails.application.configure do
     config.middleware.insert_before(ActionDispatch::Cookies, Rack::StripCookies, paths: ['/oauth2/token'])
   end
   ```

3. **Verify Middleware Order**

   To confirm the middleware's position in the stack, run:

   ```sh
   bin/rails middleware
   ```

   Ensure that `Rack::StripCookies` appears before `ActionDispatch::Cookies`.

### Using with Sinatra

If you're using Sinatra, you can integrate the middleware as follows:

```ruby
# app.rb
require 'sinatra'
require 'rack/strip-cookies'

use Rack::StripCookies, paths: ['/admin']

get '/' do
  headers "Set-Cookie" => "session=abc123; path=/admin; HttpOnly"
  "Welcome to the Home Page"
end

get '/admin' do
  "Admin Dashboard"
end

# To run the app:
# ruby app.rb
```

**Explanation:**

- The middleware is set to strip cookies for the `/admin` path.
- Requests to `/admin` will have cookies removed from both the request and response.

### Using with Padrino

While the primary integrations are with Rack-based frameworks like Ruby on Rails and Sinatra, `Rack::StripCookies` can be used with any Rack-compatible framework. Here's a brief example with **Padrino**:

```ruby
# config/apps.rb
Padrino.configure_apps do
  use Rack::StripCookies, paths: ['/api/v1/auth']
end
```

**Explanation:**

- The middleware strips cookies for the `/api/v1/auth` path within a Padrino application.

### Advanced Configuration Options

`Rack::StripCookies` provides additional configuration options to customize its behavior further.

#### Wildcard Path Patterns

You can define wildcard patterns to strip cookies from multiple subpaths matching a specific pattern.

```ruby
use Rack::StripCookies, paths: ['/api/*', '/admin/*']
```

**Explanation:**

- **`/api/*`**: Strips cookies from `/api/`, `/api/users`, `/api/v1/orders`, etc.
- **`/admin/*`**: Strips cookies from `/admin/`, `/admin/settings`, `/admin/users/list`, etc.

**Example Usage with Wildcards:**

```ruby
# config.ru
require 'rack'
require 'rack/strip-cookies'

app = Proc.new do |env|
  headers = { "Content-Type" => "text/html" }
  headers["Set-Cookie"] = "user_id=12345; path=#{env['PATH_INFO']}; HttpOnly"
  [200, headers, ["Welcome"]]
end

use Rack::StripCookies, paths: ['/api/*', '/admin/*']

run app
```

#### Inverting Path Matching

You can invert the path matching logic to strip cookies on all paths *except* the ones specified.

```ruby
use Rack::StripCookies, paths: ['/public/*', '/health'], invert: true
```

**Explanation:**

- Cookies will be stripped from all paths **except** those matching `/public/*` (e.g., `/public/images`, `/public/css`) and the exact path `/health`.

#### Multiple Paths

Specify multiple exact paths and wildcard patterns where cookies should be stripped.

```ruby
use Rack::StripCookies, paths: ['/login', '/signup', '/dashboard/*']
```

**Explanation:**

- Cookies will be stripped from `/login`, `/signup`, and any subpath under `/dashboard/` (e.g., `/dashboard/settings`, `/dashboard/profile`).

### Combining with Other Middleware

You can combine `Rack::StripCookies` with other Rack middleware to build a robust middleware stack.

```ruby
use Rack::Logger
use Rack::StripCookies, paths: ['/secure', '/private/*']
use Rack::Static, urls: ['/images'], root: 'public'
use Rack::Session::Cookie, secret: 'your_secret_key'

run YourApp::Application
```

**Explanation:**

- **`Rack::Logger`**: Logs each request.
- **`Rack::StripCookies`**: Strips cookies for `/secure` and any subpaths under `/private/`.
- **`Rack::Static`**: Serves static files from the `public` directory.
- **`Rack::Session::Cookie`**: Manages session cookies with a secret key.

## Running Tests Locally

To run the test suite on your local machine, follow these steps:

1. **Install Dependencies**

   Ensure you have the necessary Ruby version installed. You can use a version manager like `rbenv` or `rvm` to switch Ruby versions.

   ```sh
   bundle install
   ```

2. **Set Rack Version (Optional)**

   By default, tests run against the `rack` gem version specified in your `Gemfile`. To test against a different version or branch, set the `RACK` environment variable.

   ```sh
   export RACK=3-0-stable
   ```

3. **Run Tests**

   Execute the test suite using Rake:

   ```sh
   bundle exec rake test
   ```

**Note:** Ensure you have `minitest` and other testing dependencies installed.

## How to Contribute

We welcome contributions to improve this project. Here's how you can participate:

1. Fork this repository.
2. Create a new feature branch on your local copy (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push your branch to your forked repository (`git push origin my-new-feature`).
5. Open a new Pull Request on this repository for us to review and merge your changes.

## License

This project is licensed under the [MIT License](LICENSE).

## Contact

For any questions or suggestions, feel free to open an issue or contact the maintainers.
