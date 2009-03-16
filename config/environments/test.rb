# was false, but Cucumber currently broken unless true
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports
config.action_controller.consider_all_requests_local = true

# Can't test page caching without this
# (Rails turns "caches_page" into a total no-op if false;
# no after filter is ever set up, so we can't mock the "cache_page"
# call. Calling controller.perform_caching from inside a
# "before(:all)" block is too late)
config.action_controller.perform_caching = true

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

# note that we don't configure (or freeze) Cucumber because we _only_ run that locally
config.gem 'rspec', :lib => false, :version => '1.2.0'
config.gem 'rspec-rails', :lib => false, :version => '1.2.0'
