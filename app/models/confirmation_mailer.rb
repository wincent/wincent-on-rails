class ConfirmationMailer < ActionMailer::Base
  def confirmation_message confirmation
    subject     'wincent.com requests that you confirm your email address'
    body({
      :address          => confirmation.email.address,
      :confirmation_url => confirmation_url(confirmation),
      :cutoff           => confirmation.cutoff.utc
      })
    recipients  confirmation.email.address
    bcc         APP_CONFIG['admin_email']
    from        APP_CONFIG['admin_email']
    sent_on     Time.now
    headers     {}
  end
end
