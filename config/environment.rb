# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

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

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_wincent_on_rails_session',
    :secret      => '26c5cd7d236db2b6add7dfd99b667227739fce2e0be44b00e89ee774368c9862fccb3e1ad00c57b872263f9aa714625ee8e273b929ac9fbfa151d11964f68a11'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  config.gem 'wikitext', :version => '>= 1.1.1'
end

require 'active_record/acts/taggable'
require 'active_record/acts/searchable'
require 'custom_atom_feed_helper'
require 'authentication'
require 'sortable'

# NOTE: can move these into a rails/init.rb file in the gem itself
require 'wikitext/string'
require 'wikitext/rails'

Haml::Template::options[:ugly] = true
Sass::Plugin.options[:style] = :compact

APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/app_config.yml")
