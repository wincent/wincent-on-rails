source 'http://rubygems.org'

gem 'bundler'
gem 'haml'
gem 'mysql2'
gem 'rails',            '3.1.0.rc3'
gem 'memcache-client'
gem 'unicorn',          '~> 1.1.3'
gem 'rake'
gem 'sass'
gem 'wikitext',         '3.0b'
gem 'wopen3'

group :development, :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
end

group :development do
  gem 'ruby-debug'
end

group :test do
  # TODO: try zombie/capybara-zombie
  gem 'akephalos',        :git => 'https://github.com/hiroshi/akephalos.git',
                          :branch => 'capybara_0.4.0_or_newer'
  gem 'autotest-rails',   :require => nil
  gem 'capybara',         :git => 'git://github.com/jnicklas/capybara.git'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'mkdtemp'
  gem 'rcov'
  gem 'rr'
  gem 'timecop'
end
