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

  # on-demand cache expiration from rake, RSpec etc
  def self.expire_all
    sweeper = new
    Topic.all.each { |topic| sweeper.expire_cache topic }
  end
end # class TopicSweeper
