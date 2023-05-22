source "https://rubygems.org"

gemspec

rack_branch = ENV["RACK"] || "3-0-stable"

gem "rack", git: "https://github.com/rack/rack.git", ref: rack_branch || rack_version

group :test do
  gem "rack-test"
  gem "minitest"
end
