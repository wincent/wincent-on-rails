Rails.application.config.middleware.insert_after \
  ActionDispatch::Flash, CacheFriendlyFlash
Rails.application.config.middleware.use ExceptionReporter
