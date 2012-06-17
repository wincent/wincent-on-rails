class CommentSweeper < ActionController::Caching::Sweeper
  observe Comment

  extend  Sweeping
  include Sweeping

  # on-demand cache expiration from Rake (`rake cache:clear)`, RSpec etc
  def self.expire_all
    Comment.all.each do |comment|
      paths_for_comment(comment).each do |path|
        safe_expire path
      end
    end
  end

  def after_destroy(comment)
    expire_cache comment
  end

  def after_save(comment)
    expire_cache comment
  end

private

  def expire_cache(comment)
    paths_for_comment(comment).each do |path|
      safe_expire path
    end
  end

  module PathHelpers

  private

    def paths_for_comment comment
      paths = []
      commentable = comment.commentable
      case commentable
      when Article
        paths << article_path(commentable)
      when Issue
        paths << issue_path(commentable)
      when Post
        paths << post_path(commentable)
      when Snippet
        paths << snippet_path(commentable, '.atom')
        paths << snippet_path(commentable) # .html
      when Topic
        forum = commentable.forum
        paths << forum_topic_path(forum, commentable) if forum
      when Tweet
        paths << tweet_path(commentable, '.atom')
        paths << tweet_path(commentable) # .html
      end
      paths
    end
  end

  extend  PathHelpers
  include PathHelpers

end # class CommentSweeper
