source 'http://rubygems.org'

# List most of the gems under the "ruby_18" platform to prevent Bundler
# from freaking out when we fire up a JRuby (Celerity) child process in
# our acceptance specs; see:
#   http://github.com/carlhuda/bundler/issues/issue/407
platforms :ruby_18 do
  gem 'haml',             '>= 3.0.14'
  gem 'mysql',            '2.8.1'
  gem 'rails',            '3.0.0.rc'
  gem 'wikitext',         '2.0'

  group :development, :test do
    gem 'factory_girl_rails'                  # want factories in development console
    gem 'rspec-rails',    '>= 2.0.0.beta.17'  # needed for generators to work
  end

  group :development do
    gem 'ruby-debug'
  end

  group :test do
    gem 'autotest',       :require => nil
    gem 'capybara',       :git => 'git://github.com/jnicklas/capybara.git'
    gem 'culerity'
    gem 'database_cleaner'
    gem 'hpricot'
    gem 'launchy'
    gem 'mkdtemp'
    gem 'mongrel',        :require => nil
    gem 'rcov'
    gem 'rr',             :git => 'git://github.com/btakita/rr.git'
    gem 'steak',          :git => 'git://github.com/cavalle/steak.git'
  end
end

platforms :jruby do
  group :test do
    gem 'celerity',       # :git => 'git://github.com/jarib/celerity.git',
                          '>= 0.8.0.beta.1'
    gem 'jruby-openssl'
  end
end
