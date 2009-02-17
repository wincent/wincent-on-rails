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
    path = path_for_comment comment
    expire_page(path) if path
  end

  def path_for_comment comment
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
    path
  end

  # on-demand cache expiration from rake, RSpec etc
  def self.expire_all
    # see notes in the IssueSweeper for full explanation of why we do it this way
    Comment.all.each do |comment|
      relative_path = instance.path_for_comment comment
      absolute_path = ActionController::Base.send(:page_cache_path, relative_path)
      File.delete absolute_path if File.exist?(absolute_path)
    end
  end
end # class CommentSweeper
