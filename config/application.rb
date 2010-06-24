require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

require 'yaml'
APP_CONFIG = YAML.load_file File.join(File.dirname(__FILE__), 'app_config.yml')

module Wincent
  class Application < Rails::Application
    config.load_paths += %W( #{config.root}/app/sweepers )
    config.time_zone = 'UTC'
    config.encoding = "utf-8"
    config.filter_parameters += [ :passphrase ]

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
