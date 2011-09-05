source 'http://rubygems.org'

gem 'bundler'
gem 'haml'
gem 'mysql2'
gem 'rails',            '3.1.0'
gem 'memcache-client'
gem 'unicorn'
gem 'rake'
gem 'sass'
gem 'wikitext',         '3.0b'
gem 'wopen3'

group :development, :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'ruby-debug19'
end

group :test do
  # TODO: try zombie/capybara-zombie
  gem 'akephalos',        :git => 'https://github.com/hiroshi/akephalos.git',
                          :branch => 'capybara_0.4.0_or_newer'
  gem 'autotest-rails',   :require => nil
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'mkdtemp',          '>= 1.2.1'
  gem 'rcov'
  gem 'rr'
  gem 'timecop'
end
