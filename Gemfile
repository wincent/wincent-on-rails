source 'http://rubygems.org'

#gem 'ruby-debug'

gem 'haml',     '3.0.12'
gem 'mysql',    '2.8.1'
gem 'rails',    '3.0.0.beta4'
gem 'wikitext', '1.12'

group :cucumber, :development, :test do
  gem 'fixture_replacement', '3.0.1'
end

# TODO: replace Cucumber with Steak
group :cucumber, :test do
  gem 'rspec-rails', '>= 2.0.0.beta.11'
end

group :cucumber do
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'culerity'
end

group :test do
  gem 'hpricot', '0.6.164'
  gem 'mkdtemp', '1.1.1'
end
