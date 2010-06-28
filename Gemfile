source 'http://rubygems.org'

#gem 'ruby-debug'

gem 'haml',             '3.0.12'
gem 'mysql',            '2.8.1'
gem 'rails',            '3.0.0.beta4'
gem 'wikitext',         '2.0'

group :development, :test do
  gem 'factory_girl_rails'
end

group :test do
  gem 'capybara'
  gem 'culerity'
  gem 'database_cleaner'
  gem 'hpricot'
  gem 'launchy'
  gem 'mkdtemp'
  gem 'mongrel',        :require => nil
  gem 'rr'
  gem 'rspec-rails',    '>= 2.0.0.beta.13'
  gem 'steak',          :git => 'git://github.com/cavalle/steak.git'

  # for JRuby: just get them installed and in the load path, but don't require them
  gem 'celerity',       :require => nil
  gem 'jruby-openssl',  :require => nil
end
