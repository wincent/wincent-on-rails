ENV["RAILS_ENV"] ||= "test"
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require File.dirname(__FILE__) + '/controller_helpers'
require 'spec/autorun'
require 'spec/rails'

# can't use the config.include trick with FixtureReplacement
# (breaks zillions of specs)
include FixtureReplacement

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  config.include(ControllerHelpers, :type => :controller)
end

# custom matchers
require File.join(File.dirname(__FILE__), 'matchers', 'validation')
require File.join(File.dirname(__FILE__), 'matchers', 'mass_assignment')
require File.join(File.dirname(__FILE__), 'matchers', 'atom')
