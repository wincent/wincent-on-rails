class CommentMailer < ActionMailer::Base
  def new_comment_alert comment
    subject     "new comment alert from #{APP_CONFIG['host']}"
    body({
      :comment          => comment,
      :comment_url      => comment_url(comment),
      :edit_comment_url => edit_comment_url(comment),
      :moderation_url   => admin_dashboard_url
      })
    recipients  APP_CONFIG['admin_email']
    from        APP_CONFIG['admin_email']
    sent_on     Time.now
    headers     {}
  end
end
