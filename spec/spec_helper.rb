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
  config.alias_it_should_behave_like_to :it_has_behavior, 'has behavior:'
  config.include ControllerExampleGroupHelpers, :example_group => {
    :file_path => %r{\bspec/controllers/}
  }
  config.include RoutingExampleGroupHelpers, :example_group => {
    :file_path => %r{\bspec/routing/}
  }
  config.include ViewExampleGroupHelpers, :example_group => {
    :file_path => %r{\bspec/views/}
  }
  config.backtrace_clean_patterns = config.backtrace_clean_patterns + [
    %r{/Library/},
    %r{/\.bundle/}
  ]
end

# Bundler regression: http://github.com/carlhuda/bundler/issues/issue/478
# beta 1.0.0.beta.9 breaks acceptance tests involving Celerity
if ENV['RUBYOPT']
  ENV['RUBYOPT'] = ENV['RUBYOPT'].gsub(%r{-r\s*bundler/setup}, '')
end
