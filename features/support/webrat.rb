# truncate all tables (Selenium doesn't use transactional fixtures)
Wincent::Test::truncate_all_tables

Cucumber::Rails::World.use_transactional_fixtures = true

Webrat.configure do |config|
  config.mode = :rails
end
