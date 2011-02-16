class CommentSweeper < ActionController::Caching::Sweeper
  observe Comment

  # Rails BUG: https://rails.lighthouseapp.com/projects/8994/tickets/4868
  include Rails.application.routes.url_helpers

  def after_destroy comment
    expire_cache comment
  end

  def after_save comment
    expire_cache comment
  end

  def expire_cache comment
    paths_for_comment(comment).each do |path|
      expire_page(path)
    end
  end

  def paths_for_comment comment
    paths = []
    commentable = comment.commentable
    case commentable
    when Article
      paths << article_path(commentable) + '.atom'
    when Issue
      paths << issue_path(commentable) + '.atom'
    when Post
      paths << post_path(commentable) + '.atom'
    when Snippet
      paths << snippet_path(commentable) + '.atom'
      paths << snippet_path(commentable) + '.html'
    when Topic
      forum = commentable.forum
      paths << (forum_topic_path(forum, commentable) + '.atom') if forum
    when Tweet
      paths << tweet_path(commentable) + '.atom'
      paths << tweet_path(commentable) + '.html'
    end
    paths
  end

  # on-demand cache expiration from rake, RSpec etc
  def self.expire_all
    # see notes in the IssueSweeper for full explanation of why we do it this way
    Comment.all.each do |comment|
      relative_paths = instance.paths_for_comment comment
      relative_paths.each do |relative_path|
        absolute_path = ActionController::Base.send(:page_cache_path, relative_path)
        File.delete absolute_path if File.exist?(absolute_path)
      end
    end
  end
end # class CommentSweeper
