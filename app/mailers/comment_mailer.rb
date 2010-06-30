class CommentMailer < ActionMailer::Base
  default :return_path => APP_CONFIG['support_email']

  def new_comment_alert comment
    message = Message.create \
      :related            => comment,
      :to_header          => APP_CONFIG['admin_email'],
      :from_header        => APP_CONFIG['support_email'],
      :subject_header     => "new comment alert from #{APP_CONFIG['host']}",
      :incoming           => false

    @comment          = comment
    @comment_url      = comment_url(comment)
    @edit_comment_url = edit_comment_url(comment)
    @moderation_url   = admin_dashboard_url

    mail  :subject    => message.subject_header,
          :to         => message.to_header,
          :from       => message.from_header,
          :date       => Time.now,
          :message_id => message.message_id_header
  end
end
