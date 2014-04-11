require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  Bundler.require *Rails.groups(:assets => %w(development test))
end

require 'yaml'
APP_CONFIG = YAML.load_file File.join(File.dirname(__FILE__), 'app_config.yml')

module Wincent
  class Application < Rails::Application
    observers = Dir["#{config.root}/app/observers/*_observer.rb"]
    config.active_record.observers = observers.map do |observer|
      File.basename(observer).split('.').first.to_sym
    end
    config.active_record.whitelist_attributes = true

    # will eventually want to set this to `false` (or just delete it; it is the
    # default as of Rails 4.0.0) to play nicely with Backbone
    config.active_record.include_root_in_json = true

    config.autoload_paths += %W(
      #{config.root}/app/observers
      #{config.root}/lib
    )
    config.assets.enabled      = true
    config.assets.version      = '3.0'
    config.encoding            = 'utf-8'
    config.filter_parameters  += [:passphrase]
    config.time_zone           = 'UTC'

    url_options = {
      protocol:  APP_CONFIG['protocol'],
      host:      APP_CONFIG['host'],
    }.tap do |options|
      options[:port] = APP_CONFIG['port'] unless APP_CONFIG['port'].in?([80, 443])
    end
    config.action_mailer.default_url_options = url_options
  end
end
