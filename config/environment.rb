# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

require 'yaml'
APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/app_config.yml")

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Only load the plugins named here, in the order given. By default, all plugins
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  config.load_paths << "#{RAILS_ROOT}/app/sweepers"

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  config.action_controller.session = {
    :session_key => APP_CONFIG['session_key'],
    :secret      => APP_CONFIG['session_secret']
  }

  # Currently trialling using the cookie-based session store;
  # no plans to remove the old infrastructure (database etc) yet.
  # See: http://rails.wincent.com/issues/1142
  #config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  config.gem 'wikitext', :version => '>= 1.3.2'
  config.gem 'haml', :version => '2.0.6'
end

# Sometimes we need a reasonable, stable default date (for example, to provide
# an "updated at" date for an empty Atom feed; we don't want to use "Time.now"
# in such cases as that might confuse newsreaders).
# Seeing as this is a Rails app, use the "Rails Epoch" rather than the UNIX one.
RAILS_EPOCH = RAILS_1_0_0_RELEASE_DATE = Date.civil(2005, 12, 13)
