require 'capybara/rails'

RSpec.configuration.include Capybara, :type => :acceptance

# see: https://github.com/cavalle/steak/issues/20
RSpec.configure do |config|
  config.before do
    Capybara.reset_sessions!
  end
end
