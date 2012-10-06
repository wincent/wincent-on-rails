Wincent::Application.configure do
  STATIC_ASSET_HOSTS = [
    'd1qyd8e11adcyw.cloudfront.net',  # cdn01-wincent.com
    'd3fuzw120je1e7.cloudfront.net',  # cdn02-wincent.com
    'dhnj09q3kacqc.cloudfront.net',   # cdn03-wincent.com
    'd8c1zvn3ij304.cloudfront.net',   # cdn04-wincent.com
  ]

  config.action_controller.asset_host = proc do |source|
    'https://' + STATIC_ASSET_HOSTS[source.hash % STATIC_ASSET_HOSTS.size]
  end

  config.action_controller.perform_caching  = true
  config.action_dispatch.x_sendfile_header  = 'X-Accel-Redirect'
  config.action_mailer.delivery_method      = :sendmail
  config.active_support.deprecation         = :notify
  config.assets.compile                     = false
  config.assets.compress                    = true
  config.assets.digest                      = true
  config.cache_classes                      = true
  config.cache_store                        = :dalli_store, '127.0.0.1'
  config.consider_all_requests_local        = false
  config.serve_static_assets                = false
end
