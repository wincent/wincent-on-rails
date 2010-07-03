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
  config.mock_framework :rr
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.include ControllerSpecHelpers, :example_group => { :file_path => %r{\bspec/controllers/} }
  config.include MailerSpecHelpers, :example_group => { :file_path => %r{\bspec/mailers/} }
end
