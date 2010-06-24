module MailerSpecHelpers
  extend ActiveSupport::Concern

  included do
    Rails.configuration.action_mailer.default_url_options.each do |key, value|
      default_url_options[key] = value
    end
  end

  include Rails.application.routes.url_helpers
end
