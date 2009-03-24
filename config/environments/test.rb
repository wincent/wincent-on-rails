# was false, but Cucumber currently broken unless true
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports
config.action_controller.consider_all_requests_local = true

# can't test page caching if this is true
# but can't set it to true or we'll fill up public with cached garbage
# whenever we do "cap spec"
config.action_controller.perform_caching = false

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

# note that we don't configure (or freeze) Cucumber because we _only_ run that locally
config.gem 'rspec', :lib => false, :version => '1.2.2'
config.gem 'rspec-rails', :lib => false, :version => '1.2.2'
