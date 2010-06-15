require 'database_cleaner'

DatabaseCleaner.strategy = :truncation

Rspec.configure do |config|
  config.use_transactional_fixtures = false

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end
end
