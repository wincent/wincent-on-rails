ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

Dir[Rails.root.join('spec/support/**/*.rb')].each {|f| require f}

RSpec.configure do |config|
  config.after :each do
    DatabaseCleaner.clean
  end

  config.alias_it_should_behave_like_to :it_has_behavior, 'has behavior:'
  config.backtrace_exclusion_patterns += [
    %r{/Library/},
    %r{/\.bundle/},
  ]

  config.before :each do
    if Capybara.current_driver == :rack_test
      DatabaseCleaner.strategy = :transaction # for speed
    else
      DatabaseCleaner.strategy = :truncation
    end
    DatabaseCleaner.start
  end

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.mock_framework = :rr
  config.use_transactional_fixtures = false
  config.treat_symbols_as_metadata_keys_with_true_values = true # needed until RSpec 3
  config.include ControllerExampleGroupHelpers, type: :controller
  config.include GitSpecHelpers, example_group: {
    file_path: %r{\bspec/lib/git/},
  }
  config.include FeatureExampleGroupHelpers, type: :feature
  config.include ViewExampleGroupHelpers, type: :view
end
