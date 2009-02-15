# Rails 2.3.0 BUG: uninitialized constant ActionController::Caching::Sweeper
# only occurs in development environment (where cache_classes is false)
# http://groups.google.com/group/rubyonrails-talk/t/323ff7ec2d95ee32
begin
  ActionController::Caching::Sweeper
rescue NameError
  require 'rails/actionpack/lib/action_controller/caching/sweeping'
end

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
