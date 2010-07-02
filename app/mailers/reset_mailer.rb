class ResetMailer < ActionMailer::Base
  default :return_path => APP_CONFIG['support_email']

  def reset_message reset
    message = Message.create \
      :related            => reset,
      :to_header          => reset.email.address,
      :from_header        => APP_CONFIG['support_email'],
      :subject_header     => 'wincent.com forgotten passphrase helper',
      :incoming           => false

    @address    = message.to_header
    @reset_url  = reset_url(reset) # shows form to change passphrase
    @cutoff     = reset.cutoff.utc

    mail  :subject    => message.subject_header,
          :to         => message.to_header,
          :bcc        => APP_CONFIG['admin_email'],
          :from       => message.from_header,
          :date       => Time.now,
          :message_id => message.message_id_header
  end
end
