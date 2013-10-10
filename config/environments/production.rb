Wincent::Application.configure do
  STATIC_ASSET_HOSTS = [
    'd3ogqji57fkqg9.cloudfront.net',  # cdn01
    'd19zmavcjzsuj4.cloudfront.net',  # cdn02
    'djfaa0bz60cz6.cloudfront.net',   # cdn03
    'd2tdr4rkgjw2gh.cloudfront.net',  # cdn04
  ]

  config.action_controller.asset_host = -> (source) {
    'https://' + STATIC_ASSET_HOSTS[source.hash % STATIC_ASSET_HOSTS.size]
  }

  config.action_controller.perform_caching  = true
  config.action_dispatch.x_sendfile_header  = 'X-Accel-Redirect'
  config.action_mailer.delivery_method      = :smtp
  config.action_mailer.smtp_settings = {
    address:              'smtp.gmail.com',
    port:                 587,
    user_name:            'support@wincent.com',
    password:             APP_CONFIG['support_password'],
    authentication:       :plain,
    domain:               'wincent.com',
    enable_starttls_auto: true,
  }
  config.active_support.deprecation         = :notify
  config.assets.compile                     = false
  config.assets.compress                    = true
  config.assets.digest                      = true
  config.assets.paths                      += Rails.root + 'app/assets/fonts'
  config.assets.precompile                 += /\.(eot|svg|ttf|woff)\z/
  config.cache_classes                      = true
  config.cache_store                        = :dalli_store, '127.0.0.1'
  config.consider_all_requests_local        = false
  config.eager_load                         = true
  config.serve_static_assets                = false
end
