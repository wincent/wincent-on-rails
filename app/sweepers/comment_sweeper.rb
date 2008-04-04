class CommentSweeper < ActionController::Caching::Sweeper

  # NOTE: routing helpers (forum_topic_path etc) won't work if you declare a multi-model sweeper, so beware!
  observe Comment

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
    when Issue:   # TODO: don't have per-issue feeds yet
    when Post:    # TODO: don't have per-post feeds yet
    when Topic
      forum = commentable.forum
      path = (forum_topic_path(forum, commentable) + '.atom') if forum
    end
    expire_page(path) if path
  end
end # class TopicSweeper
