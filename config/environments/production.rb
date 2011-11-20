Wincent::Application.configure do
  config.action_controller.perform_caching  = true
  config.action_dispatch.x_sendfile_header  = 'X-Accel-Redirect'
  config.action_mailer.delivery_method      = :sendmail
  config.active_support.deprecation         = :notify
  config.assets.compile                     = false
  config.assets.compress                    = true
  config.assets.digest                      = true
  config.cache_classes                      = true
  config.cache_store                        = :mem_cache_store
  config.consider_all_requests_local        = false
  config.serve_static_assets                = false
end
