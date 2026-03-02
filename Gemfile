source "https://rubygems.org"

gemspec

if ENV["RACK"] == "head"
  gem "rack", git: "https://github.com/rack/rack.git"
elsif ENV["RACK"]
  gem "rack", ENV["RACK"]
end

group :test do
  gem "rack-test"
  gem "minitest"
end
