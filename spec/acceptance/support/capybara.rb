require 'capybara/rails'

Capybara.javascript_driver = :culerity

RSpec.configure do |config|
  config.include Capybara
end
