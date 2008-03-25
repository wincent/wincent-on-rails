class TopicSweeper < ActionController::Caching::Sweeper
  observe Topic, Comment

  def after_destroy record
    expire_cache record
  end

  def after_save record
    expire_cache record
  end

  def expire_cache record
    case record
    when Topic:   topic = record
    when Comment: topic = record.commentable if record.commentable_type == 'Topic'
    else          topic = nil
    end
    expire_page(forum_topic_path(topic.forum, topic) + '.atom') if topic
  end
end # class TopicSweeper
