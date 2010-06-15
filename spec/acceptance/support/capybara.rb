require 'capybara/rails'

Capybara.javascript_driver = :culerity

Rspec.configure do |config|
  config.include Capybara
end
