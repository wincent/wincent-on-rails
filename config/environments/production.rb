# Settings specified here will take precedence over those in config/environment.rb

# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching = true
config.action_view.cache_template_loading = true

# Use a different cache store in production
config.cache_store = :mem_cache_store, APP_CONFIG['memcached_host']

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# To locally test exception mailer must run in production mode with
# APP_CONFIG['admin_email'] set to a local user on the development machine
# (eg. "wincent" rather than "win@wincent.com")
config.action_mailer.delivery_method = :sendmail
