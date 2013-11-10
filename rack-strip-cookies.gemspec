# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/strip-cookies/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-strip-cookies"
  spec.version       = Rack::StripCookies::VERSION
  spec.authors       = ["Claudio Poli"]
  spec.email         = ["claudio@icorete.ch"]
  spec.summary       = %q{Rack middleware to remove cookies at user-defined paths.}
  spec.description   = %q{Rack middleware to remove cookies at user-defined paths.}
  spec.homepage      = "http://github.com/icoretech/rack-strip-cookies"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",   "~> 1.0"
  spec.add_development_dependency "rack",      "~> 1.2.0"
  spec.add_development_dependency "rack-test", "~> 0.5.4"
end
