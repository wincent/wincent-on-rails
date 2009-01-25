class TopicMailer < ActionMailer::Base
  def new_topic_alert topic
    url_options = { :host => APP_CONFIG['host'] }
    if APP_CONFIG['port'] != 80 and APP_CONFIG['port'] != 443
      url_options[:port] = APP_CONFIG['port']
    end
    subject     "new topic alert from #{APP_CONFIG['host']}"
    body({
      :topic          => topic,
      :topic_url      => edit_forum_topic_url(topic.forum, topic, url_options),
      :moderation_url => admin_dashboard_url(url_options)
      })
    recipients  APP_CONFIG['admin_email']
    from        APP_CONFIG['admin_email']
    sent_on     Time.now
    headers     {}
  end
end
