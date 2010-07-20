require File.expand_path('../spec_helper', File.dirname(__FILE__))

RSpec.configuration.include Capybara, :type => :acceptance

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
