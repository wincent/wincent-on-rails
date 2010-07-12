ENV['RAILS_ENV'] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'factory_girl/syntax/sham'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_framework = :rr
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.include ControllerSpecHelpers,
    :example_group => { :file_path => %r{\bspec/controllers/} }
  config.include RoutingSpecHelpers,
    :example_group => { :file_path => %r{\bspec/routing/} }
  config.backtrace_clean_patterns = config.backtrace_clean_patterns + [
    %r{/Library/},
    %r{/\.bundle/}
  ]
end
