source 'http://rubygems.org'

gem 'bundler',          '~> 1.0.2'
gem 'haml',             '~> 3.0.18'

# http://groups.google.com/group/mail-ruby/browse_thread/thread/e93bbd05706478dd?pli=1
gem 'mail',             '~> 2.2.15'

gem 'mysql2'
gem 'rails',            '~> 3.0.4.rc1'
gem 'memcache-client'
gem 'unicorn',          '~> 1.1.3'
gem 'wikitext',         '>= 2.1'
gem 'wopen3',           '>= 0.3'

group :development, :test do
  gem 'factory_girl_rails'          # factories in development console
  gem 'rspec-rails',    '~> 2.4.0'  # needed for generators to work
  gem 'steak',          '~> 1.1.0'  # again, for generators
end

group :development do
  gem 'ruby-debug'
end

group :test do
  gem 'akephalos',        :git => 'git://github.com/bernerdschaefer/akephalos.git',
                          :branch => 'capybara-head'
  gem 'autotest',         :require => nil
  gem 'capybara',         '~> 0.4.0'
  gem 'database_cleaner', '~> 0.6.0'
  gem 'launchy'
  gem 'mongrel',          :require => nil
  gem 'mkdtemp',          '>= 1.2'
  gem 'rcov'
  gem 'rr',               '>= 1.0'
  gem 'webrat'
end
