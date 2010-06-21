require 'capybara/rails'

Capybara.javascript_driver = :culerity

# Capybara might make this the default soon
# See: http://groups.google.com/group/ruby-capybara/browse_thread/thread/c336f52ee28f9910
Capybara.default_selector = :css

RSpec.configure do |config|
  config.include Capybara
end
