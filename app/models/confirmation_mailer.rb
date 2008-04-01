class ConfirmationMailer < ActionMailer::Base
  def confirmation_message confirmation, request
    url_options = { :host => request.host }
    url_options[:port] = request.port if request.port != 80
    subject     'wincent.com requests that you confirm your email address'
    body({
      :address          => confirmation.email.address,
      :confirmation_url => confirm_url(confirmation, url_options),
      :cutoff           => confirmation.cutoff.utc
      })
    recipients  confirmation.email.address
    bcc         'win@wincent.com'
    from        'win@wincent.com'
    sent_on     Time.now
    headers     {}
  end
end
