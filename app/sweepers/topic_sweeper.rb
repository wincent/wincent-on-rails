class TopicSweeper < ActionController::Caching::Sweeper
  observe Topic

  extend  Sweeping
  include Sweeping

  # on-demand cache expiration from Rake (`rake cache:clear`), RSpec etc
  def self.expire_all
    Pathname.glob(Rails.root + 'public/forums/*/topics').each do |dir|
      safe_expire dir, :recurse => true
    end
  end

  def after_destroy(topic)
    expire_cache topic
  end

  def after_save(topic)
    expire_cache topic
  end

private

  def expire_cache(topic)
    safe_expire(forum_topic_path(topic.forum, topic))
  end
end # class TopicSweeper
