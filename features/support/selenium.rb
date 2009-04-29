Webrat.configure do |config|
  config.mode = :selenium
  config.application_port = 3000 # 3001 is the default

  # connect to already-running Selenium RC instance
  config.selenium_server_address = '127.0.0.1'
  config.selenium_server_port = 4444 # the default
end

Before do
  # Selenium can't use transactional fixtures
  Wincent::Test::truncate_all_tables
end
