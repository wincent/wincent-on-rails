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
    config.autoload_paths += %W(
      #{config.root}/app/observers
      #{config.root}/app/sweepers
    )
    config.assets.enabled      = true
    config.assets.version      = '1.0'
    config.encoding            = 'utf-8'
    config.filter_parameters  += [:passphrase]
    config.time_zone           = 'UTC'

    url_options = {}
    url_options[:protocol] = APP_CONFIG['protocol'] if APP_CONFIG['protocol']
    url_options[:host] = APP_CONFIG['host'] if APP_CONFIG['host']
    if APP_CONFIG['port'] and APP_CONFIG['port'] != 80 and APP_CONFIG['port'] != 443
      url_options[:port] = APP_CONFIG['port']
    end
    config.action_mailer.default_url_options = url_options
  end
end

# Sometimes we need a reasonable, stable default date (for example, to provide
# an "updated at" date for an empty Atom feed; we don't want to use "Time.now"
# in such cases as that might confuse newsreaders).
# Seeing as this is a Rails app, use the "Rails Epoch" rather than the UNIX one.
RAILS_EPOCH = RAILS_1_0_0_RELEASE_DATE = Date.civil(2005, 12, 13)
