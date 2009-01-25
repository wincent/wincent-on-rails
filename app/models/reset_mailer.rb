class ResetMailer < ActionMailer::Base
  def reset_message reset
    # TODO: allow user to set default email address
    url_options         = { :host => APP_CONFIG['host'] }
    if APP_CONFIG['port'] != 80 and APP_CONFIG['port'] != 443
      url_options[:port]  = APP_CONFIG['port']
    end
    email = reset.user.emails.first(:conditions => 'deleted_at IS NULL') || (raise ActiveRecord::RecordNotFound)
    subject     'wincent.com forgotten passphrase helper'
    body({
      :address          => email.address,
      :reset_url        => edit_reset_url(reset, url_options), # will provide user with a form to change the passphrase
      :cutoff           => reset.cutoff.utc
      })
    recipients  email.address
    bcc         APP_CONFIG['admin_email']
    from        APP_CONFIG['admin_email']
    sent_on     Time.now
    headers     {}
  end
end
