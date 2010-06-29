unless Object.const_defined? :Bundler
  puts <<-HERE

    * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    *                                                                       *
    *  WARNING: Bundler is not loaded                                       *
    *  ==============================                                       *
    *                                                                       *
    *  To ensure that the environment is set-up as defined in the Gemfile   *
    *  use either Rake:                                                     *
    *                                                                       *
    *      rake spec                                                        *
    *      rake spec:acceptance                                             *
    *                                                                       *
    *  or "bundle exec":                                                    *
    *                                                                       *
    *      bundle exec rspec spec/mailers                                   *
    *      bundle exec rspec spec/models                                    *
    *                                                                       *
    * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

    HERE
end

ENV['RAILS_ENV'] = ENV['RSPEC_RAILS_ENV'] || 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'factory_girl/syntax/sham'

# guard against user stupidity
if Object.const_defined?(:Spec) && Spec::VERSION::MAJOR == 1
  raise "RSpec 1.x is loaded: did you run 'spec' instead of 'rspec'?"
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rr
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.include ControllerSpecHelpers, :example_group => { :file_path => %r{\bspec/controllers/} }
  config.include MailerSpecHelpers, :example_group => { :file_path => %r{\bspec/mailers/} }
end

# make "bundle exec ..." and "rake spec ..." behave like "rspec ..." does
if ENV['RUBYOPT'] && ENV['RUBYOPT'] =~ %r{-r\s*bundler/setup}
  puts "Pruning RUBYOPT; current value: #{ENV['RUBYOPT']}"
  ENV['RUBYOPT'] = ENV['RUBYOPT'].gsub(%r{-r\s*bundler/setup}, '')
  puts "                     new value: #{ENV['RUBYOPT']}"
  puts "See https://wincent.com/issues/1590 for more details"
end
