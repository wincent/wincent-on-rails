class TopicSweeper < ActionController::Caching::Sweeper
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

  # on-demand cache expiration from rake, RSpec etc
  def self.expire_all
    # see the notes in the IssueSweeper for full explanation of why we do it this way
    Topic.all.each do |topic|
      relative_path = instance.send(:forum_topic_path, topic.forum, topic) + '.atom'
      absolute_path = ActionController::Base.send(:page_cache_path, relative_path)
      File.delete absolute_path if File.exist?(absolute_path)
    end
  end
end # class TopicSweeper
