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

# can run "rake spec" but can't do "RAILS_ENV=test rake gems:unpack" yet
# http://rspec.lighthouseapp.com/projects/5645/tickets/699
config.gem 'dchelimsky-rspec', :lib => 'spec', :version => '1.1.99.7'
config.gem 'dchelimsky-rspec-rails', :lib => 'spec/rails', :version => '1.1.99.7'
#config.gem 'rspec', :lib => 'spec', :version => '1.1.99.7'
#config.gem 'rspec-rails', :lib => 'spec/rails', :version => '1.1.99.7'
