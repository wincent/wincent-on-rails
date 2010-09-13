ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_framework = :rr
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.alias_it_should_behave_like_to :it_has_behavior, 'has behavior:'
  config.include ControllerExampleGroupHelpers, :type => :controller
  config.include RoutingExampleGroupHelpers, :type => :routing
  config.include ViewExampleGroupHelpers, :type => :view
  config.include GitSpecHelpers, :example_group => {
    :file_path => %r{\bspec/lib/git/}
  }
  config.backtrace_clean_patterns = config.backtrace_clean_patterns + [
    %r{/Library/},
    %r{/\.bundle/}
  ]
end

# Bundler BUG: http://github.com/carlhuda/bundler/issues/issue/478
# mongrel child process in acceptance specs gets gimped by Bundler
# we either stop Bundler from meddling with RUBYOPT, or watch our
# specs hang indefinitely
if ENV['RUBYOPT']
  ENV['RUBYOPT'] = ENV['RUBYOPT'].gsub(%r{-r\s*bundler/setup}, '')
end
