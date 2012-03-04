source 'http://rubygems.org'

gem 'bundler'
gem 'haml'
gem 'mysql2'
gem 'rails', '3.2.2'
gem 'memcache-client'
gem 'unicorn'
gem 'rake'
gem 'wikitext'
gem 'wopen3'

group :assets do
  gem 'coffee-rails'
  gem 'sass-rails'
  gem 'uglifier'
end

group :production do
  gem 'therubyracer'
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'

  # uncomment for local debugging; but never for production
  # (linecache19 is misbehaved and breaks the deploy)
  #gem 'ruby-debug19'
end

group :test do
  # TODO: try zombie/capybara-zombie
  gem 'akephalos',        :git => 'git://github.com/hiroshi/akephalos.git',
                          :branch => 'capybara_0.4.0_or_newer'
  gem 'autotest-rails',   :require => nil
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'mkdtemp'
  gem 'rr'
  gem 'timecop'
end
