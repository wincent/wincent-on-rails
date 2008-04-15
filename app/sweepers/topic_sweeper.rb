class TopicSweeper < ActionController::Caching::Sweeper
  observe Topic

  # routing helpers (forum_topic_path etc) _might_ not work without this include (behaviour seems erratic)
  include ActionController::UrlWriter

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
