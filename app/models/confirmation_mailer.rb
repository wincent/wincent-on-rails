class ConfirmationMailer < ActionMailer::Base
  def confirmation_message confirmation
    url_options = { :host => APP_CONFIG['host'] }
    url_options[:port] = APP_CONFIG['port'] if APP_CONFIG['port'] != 80
    subject     'wincent.com requests that you confirm your email address'
    body({
      :address          => confirmation.email.address,
      :confirmation_url => confirm_url(confirmation, url_options),
      :cutoff           => confirmation.cutoff.utc
      })
    recipients  confirmation.email.address
    bcc         APP_CONFIG['admin_email']
    from        APP_CONFIG['admin_email']
    sent_on     Time.now
    headers     {}
  end
end
