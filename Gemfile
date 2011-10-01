source 'http://rubygems.org'

gem 'bundler'
gem 'haml'
gem 'mysql2'
gem 'rails',            '3.1.1.rc2'
gem 'memcache-client'
gem 'unicorn'
gem 'rake'
gem 'sass'
gem 'wikitext',         '3.0b'
gem 'wopen3'

group :development, :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'

  # uncomment for local debugging; but never for production
  # (linecache19 is misbehaved and breaks the deploy)
  #gem 'ruby-debug19'
end

group :test do
  # TODO: try zombie/capybara-zombie
  gem 'akephalos',        :git => 'git://github.com/hiroshi/akephalos.git',
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
