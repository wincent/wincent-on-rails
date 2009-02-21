class ResetMailer < ActionMailer::Base
  def reset_message reset
    # TODO: allow user to set default email address
    email = reset.user.emails.first(:conditions => 'deleted_at IS NULL') || (raise ActiveRecord::RecordNotFound)
    subject(subject_header = 'wincent.com forgotten passphrase helper')
    body({
      :address          => email.address,
      :reset_url        => edit_reset_url(reset), # will provide user with a form to change the passphrase
      :cutoff           => reset.cutoff.utc
      })
    recipients(to_header = email.address)
    bcc APP_CONFIG['admin_email']
    from(from_header = APP_CONFIG['admin_email'])
    sent_on Time.now
    headers 'Message-ID' => (message_id_header = SupportMailer.new_message_id)
    Message.create  :related => reset,
                    :message_id_header => message_id_header,
                    :to_header => to_header,
                    :from_header => from_header,
                    :subject_header => subject_header,
                    :incoming => false
  end
end
