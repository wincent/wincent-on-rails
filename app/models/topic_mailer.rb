class TopicMailer < ActionMailer::Base
  def new_topic_alert topic
    subject(subject_header = "new topic alert from #{APP_CONFIG['host']}")
    body({
      :topic          => topic,
      :topic_url      => edit_forum_topic_url(topic.forum, topic),
      :moderation_url => admin_dashboard_url
      })
    recipients(to_header = APP_CONFIG['admin_email'])
    from(from_header = APP_CONFIG['admin_email'])
    sent_on Time.now
    headers 'Message-ID' => (message_id_header = TMail.new_message_id 'wincent.com')
    Message.create  :related => topic,
                    :message_id_header => message_id_header,
                    :to_header => to_header,
                    :from_header => from_header,
                    :subject_header => subject_header,
                    :incoming => false
  end
end
