require 'capybara/rails'

# Capybara might make this the default soon
# See: http://groups.google.com/group/ruby-capybara/browse_thread/thread/c336f52ee28f9910
Capybara.default_selector = :css

RSpec.configuration.include Capybara, :type => :acceptance
