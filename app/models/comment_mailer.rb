class CommentMailer < ActionMailer::Base
  def new_comment_alert comment
    url_options = { :host => APP_CONFIG['host'] }
    url_options[:port] = APP_CONFIG['port'] if APP_CONFIG['port'] != 80
    subject     "new comment alert from #{APP_CONFIG['host']}"
    body({
      :comment              => comment,
      :comment_url          => edit_comment_url(comment, url_options),
      :moderation_url       => admin_dashboard_url(url_options)
      })
    recipients  APP_CONFIG['admin_email']
    from        APP_CONFIG['admin_email']
    sent_on     Time.now
    headers     {}
  end
end
