class ConfirmationMailer < ActionMailer::Base
  default :return_path => APP_CONFIG['support_email']

  def confirmation_message confirmation
    message = Message.create \
      :related            => confirmation,
      :to_header          => confirmation.email.address,
      :from_header        => APP_CONFIG['support_email'],
      :subject_header     => 'wincent.com requests that you confirm your email address',
      :incoming           => false

    @address          = confirmation.email.address
    @confirmation_url = confirmation_url(confirmation)
    @cutoff           = confirmation.cutoff.utc

    mail  :subject    => message.subject_header,
          :to         => message.to_header,
          :bcc        => APP_CONFIG['admin_email'],
          :from       => message.from_header,
          :date       => Time.now,
          :message_id => message.message_id_header
  end
end
