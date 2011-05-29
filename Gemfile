source 'http://rubygems.org'

gem 'bundler'
gem 'haml'
gem 'mysql2'
gem 'rails',            '3.1.0.rc1'
gem 'memcache-client'
gem 'unicorn',          '~> 1.1.3'
gem 'rake'
gem 'sass'
gem 'wikitext',         '3.0b'
gem 'wopen3'

group :development, :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'rspec-core'
  gem 'steak'
end

group :development do
  gem 'ruby-debug'
end

group :test do
  # plan here is to update to capybara 1.0+
  # (completely replace webrat and steak); akephalos is a blocker for that
  # and in fact want to try replacing akephalos with zombie/capybara-zombie
  # if it will make the tests run faster
  gem 'akephalos'
  gem 'autotest-rails',   :require => nil
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'mkdtemp'
  gem 'rcov'
  gem 'rr'
  gem 'timecop'
  gem 'webrat'
end
