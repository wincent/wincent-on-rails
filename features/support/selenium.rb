Webrat.configure do |config|
  config.mode = :selenium
end

Before do
  # Selenium can't use transactional fixtures
  Wincent::Test::truncate_all_tables
end
