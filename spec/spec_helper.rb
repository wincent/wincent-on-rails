ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/autorun'
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

# used in controller specs
# should probably go in a module
def cookie_flash
  return {} unless cookies['flash']
  ActiveSupport::JSON.decode(CGI::unescape(cookies['flash']))
end

# custom matchers
require File.join(File.dirname(__FILE__), 'matchers', 'validation')
require File.join(File.dirname(__FILE__), 'matchers', 'mass_assignment')
require File.join(File.dirname(__FILE__), 'matchers', 'atom')

# Without this we have a couple of failing sessions controller specs.
#
# Note that setting ENV['HTTPS'] to 'on' here is not enough.
# Rails will create an ActionController::TestRequest instance using:
#   Rack::MockRequest.env_for("/")
# If you look in the rack source code you'll see that it sets up a
# sparse environment with default values (like "example.org" for the
# host), and doesn't consult the real environment at all in any way.
module ActionController
  class TestRequest
    def ssl?
      true
    end
  end
end

