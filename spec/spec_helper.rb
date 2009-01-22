ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'

include FixtureReplacement

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
end

# used in controller specs
def login_as user
  controller.instance_eval { @current_user = user }
  controller.stub!(:login_before) # don't let the before filter clear the user again
end

# used in controller specs
def login_as_admin
  controller.instance_eval { @current_user = create_user :superuser => true }
  controller.stub!(:login_before) # don't let the before filter clear the user again
end

# used in controller specs
def login_as_normal_user
  login_as create_user
end

# custom matchers
require File.join(File.dirname(__FILE__), 'matchers', 'validation')

# nasty hack to get specs passing
# the fake requests created by Rails always return false for "ssl?"
# so our before filter always redirects
module ActionController
  class TestRequest
    def ssl?
      true
    end
  end
end
