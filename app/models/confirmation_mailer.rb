class ConfirmationMailer < ActionMailer::Base
  def confirmation_message confirmation
    subject(subject_header = 'wincent.com requests that you confirm your email address')
    body({
      :address          => confirmation.email.address,
      :confirmation_url => confirmation_url(confirmation),
      :cutoff           => confirmation.cutoff.utc
      })
    recipients(to_header = confirmation.email.address)
    bcc APP_CONFIG['admin_email']

    # TODO: once incoming mail support is in, "from" will be support@wincent.com
    from(from_header = APP_CONFIG['admin_email'])
    sent_on Time.now
    headers 'Message-ID' => (message_id_header = SupportMailer.new_message_id)
    Message.create  :related => confirmation,
                    :message_id_header => message_id_header,
                    :to_header => to_header,
                    :from_header => from_header,
                    :subject_header => subject_header,
                    :incoming => false
  end
end
