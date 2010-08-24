source 'http://rubygems.org'

# List most of the gems under the "ruby_18" platform to prevent Bundler
# from freaking out when we fire up a JRuby (Celerity) child process in
# our acceptance specs; see:
#   http://github.com/carlhuda/bundler/issues/issue/407
platforms :ruby_18 do
  gem 'haml',             '>= 3.0.15'
  gem 'mysql2'
  gem 'rails',            '3.0.0.rc2'
  gem 'wikitext',         '2.0'
  gem 'wopen3',           '>= 0.3'

  group :development, :test do
    gem 'factory_girl_rails'              # factories in development console
    gem 'rspec-rails',    '2.0.0.beta.19' # needed for generators to work
  end

  group :development do
    gem 'ruby-debug'
  end

  group :test do
    gem 'autotest',       :require => nil
    gem 'capybara',       :git => 'git://github.com/jnicklas/capybara.git'
    gem 'culerity'
    gem 'database_cleaner', '>= 0.6.0.rc.2'
    gem 'hpricot'
    gem 'launchy'
    gem 'mkdtemp',        '>= 1.2'
    gem 'mongrel',        :require => nil
    gem 'rcov'
    gem 'rr',             '>= 1.0'
    gem 'steak',          :git => 'git://github.com/cavalle/steak.git'
  end
end

platforms :jruby do
  group :test do
    gem 'celerity',       '>= 0.8.0.beta.1'
    gem 'jruby-openssl'
  end
end
