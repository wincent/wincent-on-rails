Wincent::Application.configure do
  config.cache_classes                      = true
  config.consider_all_requests_local        = false
  config.action_controller.perform_caching  = true
  config.action_dispatch.x_sendfile_header  = 'X-Accel-Redirect'
  config.serve_static_assets                = false
  config.action_mailer.delivery_method      = :sendmail
  config.active_support.deprecation         = :notify
end
