class CommentMailer < ActionMailer::Base
  default :return_path => APP_CONFIG['support_email']

  def new_comment_alert comment
    subject_header    = "new comment alert from #{APP_CONFIG['host']}"
    to_header         = APP_CONFIG['admin_email']
    from_header       = APP_CONFIG['support_email']
    @comment          = comment
    @comment_url      = comment_url(comment)
    @edit_comment_url = edit_comment_url(comment)
    @moderation_url   = admin_dashboard_url
    headers 'Message-ID' => (message_id_header = SupportMailer.new_message_id)
    Message.create  :related            => comment,
                    :message_id_header  => message_id_header,
                    :to_header          => to_header,
                    :from_header        => from_header,
                    :subject_header     => subject_header,
                    :incoming           => false
    mail  :subject  => subject_header,
          :to       => to_header,
          :from     => from_header,
          :date     => Time.now
  end
end
