source 'http://rubygems.org'

# List most of the gems under the "ruby_18" platform to prevent Bundler
# from freaking out when we fire up a JRuby (Celerity) child process in
# our acceptance specs; see:
#   http://github.com/carlhuda/bundler/issues/issue/407
platforms :ruby_18 do
  gem 'haml',             '3.0.12'
  gem 'mysql',            '2.8.1'
  gem 'rails',            '3.0.0.beta4'
  gem 'wikitext',         '2.0'

  group :development, :test do
    gem 'factory_girl_rails'
  end

  group :development do
    gem 'ruby-debug'
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

    # until rspec-mocks > 2.0.0.beta.15 comes out, need this to stop RSpec stomping over
    # RR's mocking methods
    gem 'rspec-mocks',    :git => 'git://github.com/rspec/rspec-mocks.git'

    gem 'rspec-rails',    '>= 2.0.0.beta.13'
    gem 'steak',          :git => 'git://github.com/cavalle/steak.git'

    # Bundler BUG: these are only for JRuby, but we must still declare them
    # here too if we want them to remain installed
    gem 'celerity',       :require => nil
    gem 'jruby-openssl',  :require => nil
  end
end

platforms :jruby do
  group :test do
    # Bundler BUG: must ':require => nil' here too, otherwise Bundler will
    # try to require them even when running under MRI
    gem 'celerity',       :require => nil
    gem 'jruby-openssl',  :require => nil
  end
end
