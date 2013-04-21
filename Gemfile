source 'https://rubygems.org'

gem 'bundler'
gem 'dalli'
gem 'haml'
gem 'mysql2'
gem 'rails'
gem 'rake'
gem 'twitter'
gem 'unicorn'
gem 'wikitext'
gem 'wopen3'

group :assets do
  gem 'coffee-rails'
  gem 'compass-rails'
  gem 'oily_png'
  gem 'sass-rails'
  gem 'uglifier'
end

group :production do
  gem 'therubyracer'
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'jasmine'
  gem 'rspec-rails'

  # uncomment for local debugging; but never for production
  # (linecache19 is misbehaved and breaks the deploy)
  #gem 'ruby-debug19'
end

group :test do
  gem 'autotest-rails', require: nil
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'mkdtemp'
  gem 'rr'
  gem 'timecop'
end
