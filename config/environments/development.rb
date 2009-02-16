# reload classes on every request
config.cache_classes = false

# log error messages when you accidentally call methods on nil
config.whiny_nils = true

# show full error reports
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true

# enable caching (when testing caching)
config.action_controller.perform_caching             = true

# disable caching (when not testing caching)
#config.action_controller.perform_caching             = false
config.action_mailer.raise_delivery_errors = true
