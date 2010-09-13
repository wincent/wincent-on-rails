require 'capybara/rails'
require 'akephalos'

Capybara.javascript_driver = :akephalos

# Capybara might make this the default soon
# See: http://groups.google.com/group/ruby-capybara/browse_thread/thread/c336f52ee28f9910
Capybara.default_selector = :css

RSpec.configure do |config|
  config.include Capybara, :type => :acceptance
end
