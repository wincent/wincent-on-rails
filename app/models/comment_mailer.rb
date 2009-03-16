class CommentMailer < ActionMailer::Base
  def new_comment_alert comment
    subject(subject_header = "new comment alert from #{APP_CONFIG['host']}")
    body({
      :comment          => comment,
      :comment_url      => comment_url(comment),
      :edit_comment_url => edit_comment_url(comment),
      :moderation_url   => admin_dashboard_url
      })
    recipients(to_header = APP_CONFIG['admin_email'])
    from(from_header = APP_CONFIG['support_email'])
    sent_on     Time.now
    headers 'Message-ID' => (message_id_header = SupportMailer.new_message_id)
    Message.create  :related => comment,
                    :message_id_header => message_id_header,
                    :to_header => to_header,
                    :from_header => from_header,
                    :subject_header => subject_header,
                    :incoming => false
  end
end
