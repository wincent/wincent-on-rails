# reload classes on every request
config.cache_classes = false

# log error messages when you accidentally call methods on nil
config.whiny_nils = true

# show full error reports
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true

# enable caching (when testing caching)
# beware of doing this on the production server (it can pollute the public
# directory with cached files from the wrong environment)
#config.action_controller.perform_caching             = true

# disable caching (when not testing caching)
config.action_controller.perform_caching             = false

config.action_mailer.raise_delivery_errors = true

config.after_initialize do
  # as of Rails 2.3 won't start up unless we defer this til after initialization
  # http://rails.lighthouseapp.com/projects/8994/tickets/1977
  Sass::Plugin.options[:always_update] = true
  Sass::Plugin.options[:always_check] = true
end
