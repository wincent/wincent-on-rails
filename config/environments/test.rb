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

config.gem 'rspec', :lib => false, :version => '1.2.5'
config.gem 'rspec-rails', :lib => false, :version => '1.2.5'

# not vendoring cucumber/webrat right now because of the list of dependencies
#
# - [I] cucumber = 0.2.3
#    - [I] term-ansicolor >= 1.0.3
#    - [I] treetop >= 1.2.5
#       - [I] polyglot
#    - [I] polyglot >= 0.2.5
#    - [I] diff-lcs >= 1.1.2
#    - [I] builder >= 2.1.2
# - [I] webrat = 0.4.3
#    - [I] nokogiri >= 1.2.0
#
#config.gem 'cucumber', :lib => false, :version => '0.2.3'
#config.gem 'webrat', :lib => false, :version => '0.4.3'
