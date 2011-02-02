module PostsHelper
  def comment_count number
    pluralizing_count number, 'comment'
  end

  def comments_link post
    # BUG: comment count is inaccurate here (includes non-public comments and
    #      comments awaiting moderation), but we can't do an actual query here
    #      (such as comments.published.count) without running into N+1
    #      select problems; see lib/commentable for some notes on how we might
    #      be able to implement a custom counter cache to work around this
    #      problem
    if post.accepts_comments? || post.comments_count > 0
      link_to comment_count(post.comments_count),
        post_path(post, :anchor => 'comments'),
        :class => 'comments_link'
    else
      ''
    end
  end
end
