source 'http://rubygems.org'

gem 'haml',             '~> 3.0.18'
gem 'mysql2'
gem 'rails',            '3.0.0'
gem 'memcache-client'
gem 'unicorn',          '~> 1.1.3'
gem 'wikitext',         '2.0'
gem 'wopen3',           '>= 0.3'

group :development, :test do
  gem 'factory_girl_rails'                # factories in development console
  gem 'rspec-rails',    '2.0.0.rc'        # needed for generators to work
  gem 'steak',          '>= 1.0.0.beta.2' # again, for generators
end

group :development do
  gem 'ruby-debug'
end

group :test do
  gem 'akephalos',      :git => 'git://github.com/bernerdschaefer/akephalos.git',
                        :branch => 'capybara-head'
  gem 'autotest',       :require => nil
  gem 'capybara',       :git => 'git://github.com/jnicklas/capybara.git'
  gem 'database_cleaner', '>= 0.6.0.rc.2'
  gem 'launchy'
  gem 'mongrel',        :require => nil
  gem 'mkdtemp',        '>= 1.2'
  gem 'rcov'
  gem 'rr',             '>= 1.0'
  gem 'webrat'
end
