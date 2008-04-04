class TopicSweeper < ActionController::Caching::Sweeper

  # NOTE: routing helpers (forum_topic_path etc) won't work if you declare a multi-model sweeper, so beware!
  observe Topic

  def after_destroy topic
    expire_cache topic
  end

  def after_save topic
    expire_cache topic
  end

  def expire_cache topic
    expire_page(forum_topic_path(topic.forum, topic) + '.atom')
  end
end # class TopicSweeper
