# truncate all tables (Selenium doesn't use transactional fixtures)
Wincent::Test::truncate_all_tables

Cucumber::Rails.use_transactional_fixtures

Webrat.configure do |config|
  config.mode = :rails
end
