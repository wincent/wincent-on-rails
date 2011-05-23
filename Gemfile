source 'http://rubygems.org'

gem 'bundler',          '>= 1.0.2'
gem 'haml',             '>= 3.0.18'
gem 'mysql2'
gem 'rails',            '3.1.0.rc1'
gem 'memcache-client'
gem 'unicorn',          '~> 1.1.3'
gem 'sass'
gem 'wikitext',         '>= 2.1'
gem 'wopen3',           '>= 0.3'

group :development, :test do
  gem 'factory_girl_rails'          # factories in development console
  gem 'rspec-rails'
  gem 'rspec-core',     '2.6.0'     # 2.6.2 has a buggy gemspec, waiting for > 2.6.2
  gem 'steak',          '>= 1.1.0'  # again, for generators
end

group :development do
  gem 'ruby-debug'
end

group :test do
  gem 'akephalos',        '>= 0.2.5'
  gem 'autotest-rails',   :require => nil
  gem 'capybara',         '>= 0.4.0'
  gem 'database_cleaner', '>= 0.6.0'
  gem 'launchy'
  gem 'mkdtemp',          '>= 1.2'
  gem 'rcov'
  gem 'rr',               '>= 1.0'
  gem 'timecop'
  gem 'webrat'
end
