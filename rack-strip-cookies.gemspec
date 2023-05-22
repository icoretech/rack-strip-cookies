lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rack/strip-cookies/version"

Gem::Specification.new do |spec|
  spec.name = "rack-strip-cookies"
  spec.version = Rack::StripCookies::VERSION
  spec.authors = ["Claudio Poli"]
  spec.email = ["claudio@icorete.ch"]
  spec.summary = "Rack middleware to remove cookies at user-defined paths."
  spec.description = "Rack middleware to remove cookies at user-defined paths."
  spec.homepage = "http://github.com/icoretech/rack-strip-cookies"
  spec.license = "MIT"

  spec.files = `git ls-files`.split("\x0")
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rack", ">= 3.0"

  spec.add_development_dependency "bundler", ">= 2.2"
  spec.add_development_dependency "rack-test", ">= 2.1.0"
  spec.add_development_dependency "rake", ">= 13.0.6"
  spec.add_development_dependency "minitest", ">= 5.18.0"
end
