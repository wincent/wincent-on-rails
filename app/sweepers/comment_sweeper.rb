# Rails 2.3.0 BUG: uninitialized constant ActionController::Caching::Sweeper
# only occurs in development environment (where cache_classes is false)
# http://groups.google.com/group/rubyonrails-talk/t/323ff7ec2d95ee32
# http://rails.lighthouseapp.com/projects/8994/tickets/1977
begin
  ActionController::Caching::Sweeper
rescue NameError
  require 'rails/actionpack/lib/action_controller/caching/sweeping'
end

class CommentSweeper < ActionController::Caching::Sweeper
  observe Comment

  # routing helpers (forum_topic_path etc) _might_ not work without this include (behaviour seems erratic)
  include ActionController::UrlWriter

  def after_destroy comment
    expire_cache comment
  end

  def after_save comment
    expire_cache comment
  end

  def expire_cache comment
    path = nil
    commentable = comment.commentable
    case commentable
    when Article: # probably never will have per-Article feeds
    when Issue
      path = issue_path(commentable) + '.atom'
    when Post:    # TODO: don't have per-post feeds yet
    when Topic
      forum = commentable.forum
      path = (forum_topic_path(forum, commentable) + '.atom') if forum
    end
    expire_page(path) if path
  end

  # on-demand cache expiration from rake, RSpec etc
  def self.expire_all
    sweeper = new
    Comment.all.each { |comment| sweeper.expire_cache comment }
  end
end # class CommentSweeper
