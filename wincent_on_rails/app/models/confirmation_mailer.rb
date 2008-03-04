class ConfirmationMailer < ActionMailer::Base
  def confirmation_message confirmation, sent_at = Time.now
    subject     'wincent.com requests that you confirm your email address'
    body({
      :address          => confirmation.email.address,
      :confirmation_url => email_confirm_url(confirmation.email, confirmation, :host => 'wincent.com'),
      :cutoff           => confirmation.cutoff.utc
      })
    recipients  confirmation.email.address
    bcc         'win@wincent.com'
    from        'win@wincent.com'
    sent_on     sent_at
    headers     {}
  end
end
