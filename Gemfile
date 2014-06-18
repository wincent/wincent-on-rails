source 'https://rubygems.org'

gem 'bundler'
gem 'closure-compiler'

# TODO: delete this line after non-pre release
gem 'compass', '1.0.0.alpha.19'

gem 'compass-rails'
gem 'dalli'
gem 'haml'
gem 'mysql2'
gem 'nokogiri'
gem 'protected_attributes' # was in Rails core, extracted in 4.0
gem 'rails', '4.1.2.rc1'
gem 'rails-observers' # was in Rails core, extracted in 4.0
gem 'rake'

# working around this issue with Sass:
#   https://github.com/nex3/sass/issues/1028
# by cherry-picking this commit from Sprockets:
#   https://github.com/sstephenson/sprockets/commit/655f129fa910f7d46803fdc66d6
# on top of the 2.11.0 release (2.12.0 and 2.12.1 are horribly broken)
gem 'sprockets', path: 'vendor/gems/sprockets'

gem 'sass-rails'
gem 'unicorn'
gem 'wikitext'
gem 'wopen3'

group :development, :test do
  gem 'byebug'
  gem 'factory_girl_rails'
  gem 'hirb'
  gem 'jasmine'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'autotest-rails', require: nil
  #gem 'capybara-webkit' # pending getting things building under Ruby 2.0.0 again
  gem 'database_cleaner'
  gem 'launchy'
  gem 'mkdtemp'
  gem 'rr'
  gem 'timecop'
end
