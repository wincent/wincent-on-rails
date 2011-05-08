source 'http://rubygems.org'

gem 'bundler',          '~> 1.0.2'
gem 'haml',             '~> 3.0.18'
gem 'mysql2',           '~> 0.2.6'  # until Rails 3.1 hits
gem 'rails',            '3.1.0.beta1'
gem 'memcache-client'
gem 'unicorn',          '~> 1.1.3'
gem 'wikitext',         '>= 2.1'
gem 'wopen3',           '>= 0.3'

group :development, :test do
  gem 'factory_girl_rails'          # factories in development console
  gem 'rspec-rails',    '~> 2.4'    # needed for generators to work
  gem 'steak',          '~> 1.1.0'  # again, for generators
end

group :development do
  gem 'ruby-debug'
end

group :test do
  gem 'akephalos',        '~> 0.2.5'
  gem 'autotest-rails',   :require => nil
  gem 'capybara',         '~> 0.4.0'
  gem 'database_cleaner', '~> 0.6.0'
  gem 'launchy'
  gem 'mkdtemp',          '>= 1.2'
  gem 'rcov'
  gem 'rr',               '>= 1.0'
  gem 'timecop'
  gem 'webrat'
end
