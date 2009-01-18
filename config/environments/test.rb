# was false, but Cucumber currently broken unless true
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

# One day will install RSpec as a gem as it will make upgrades easier;
# but for now (Rails 2.2.2, RSpec 1.1.12) it doesn't work.
#config.gem 'rspec',       :version => '1.1.12'
#config.gem 'rspec-rails', :version => '1.1.12'
