source 'https://rubygems.org'

gemspec

gem 'rake'

github = 'git://github.com/%s.git'
repos  = { 'rack' => github % 'rack/rack' }

%w(rack).each do |lib|
  dep = case ENV[lib]
        when 'stable', nil then nil
        when /(\d+\.)+\d+/ then '~> ' + ENV[lib].sub("#{lib}-", '')
        else { git: repos[lib], branch: dep }
        end
  gem lib, dep
end

group :test do
  gem 'rack-test'
  gem 'coveralls', require: false
end
