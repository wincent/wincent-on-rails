Webrat.configure do |config|
  config.mode = :selenium
  config.application_port = 3000
end

Before do
  # Selenium can't use transactional fixtures
  Wincent::Test::truncate_all_tables
end
