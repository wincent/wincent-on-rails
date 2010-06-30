class TopicMailer < ActionMailer::Base
  default :return_path => APP_CONFIG['support_email']

  def new_topic_alert topic
    message = Message.create \
      :related            => topic,
      :message_id_header  => SupportMailer.new_message_id,
      :to_header          => APP_CONFIG['admin_email'],
      :from_header        => APP_CONFIG['support_email'],
      :subject_header     => "new topic alert from #{APP_CONFIG['host']}",
      :incoming           => false

    @topic          = topic
    @topic_url      = edit_forum_topic_url(topic.forum, topic)
    @moderation_url = admin_dashboard_url

    mail  :subject    => message.subject_header,
          :to         => message.to_header,
          :from       => message.from_header,
          :date       => Time.now,
          :message_id => message.message_id_header
  end
end
