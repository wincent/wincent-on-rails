source 'https://rubygems.org'

gem 'bundler'
gem 'coffee-rails'
gem 'compass-rails', '~> 2.0.alpha'
gem 'dalli'
gem 'haml'
gem 'mysql2'
gem 'nokogiri'
gem 'oily_png'
gem 'protected_attributes' # was in Rails core, extracted in 4.0
gem 'rails'
gem 'rails-observers' # was in Rails core, extracted in 4.0
gem 'rake'
gem 'sass-rails'
gem 'twitter'
gem 'uglifier'
gem 'unicorn'
gem 'wikitext'
gem 'wopen3'

group :production do
  # if we move to a later version (eg. 0.12.0), then we'll depend on libv8
  # 3.16.14.3, but that won't compile on Fedora 8, so stay locked here
  gem 'therubyracer', '0.11.4' # implies libv8 3.11.8.17
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'jasmine'
  gem 'rspec-rails'
  gem 'debugger'
end

group :test do
  gem 'autotest-rails', require: nil
  gem 'capybara-webkit'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'mkdtemp'
  gem 'rr'
  gem 'timecop'
end
