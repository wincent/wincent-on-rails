Rails.application.config.session_store :cookie_store, :key => APP_CONFIG['session_key']
Rails.application.config.cookie_secret = APP_CONFIG['session_secret']
