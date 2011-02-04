require 'capybara/rails'

# see: https://github.com/cavalle/steak/issues/20
RSpec.configure do |config|
  config.before do
    Capybara.reset_sessions!
  end
end
