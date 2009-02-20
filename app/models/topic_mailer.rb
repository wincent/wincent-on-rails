class TopicMailer < ActionMailer::Base
  def new_topic_alert topic
    subject     "new topic alert from #{APP_CONFIG['host']}"
    body({
      :topic          => topic,
      :topic_url      => edit_forum_topic_url(topic.forum, topic),
      :moderation_url => admin_dashboard_url
      })
    recipients  APP_CONFIG['admin_email']
    from        APP_CONFIG['admin_email']
    sent_on     Time.now
    headers     {}
  end
end
