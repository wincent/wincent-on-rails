module PostsHelper
  def excerpt_html post, options = {}
    level = options[:base_heading_level] || 1
    post.excerpt.w :base_heading_level => level
  end

  def comment_count number
    pluralizing_count number, 'comment'
  end

  def comments_link post
    # NOTE: the problem with this method was that it was causing an "n +  1"
    # SELECT problem in the index action basically, calling "ham_count"
    # unavoidably provokes a database query for each post; the counter_cache is
    # useless (and unused) in this case.
    #
    # Previously, the code looked like this:
    #
    #   if post.accepts_comments? || post.comments.ham_count > 0
    #     link_to comment_count(post.comments.ham_count) ...
    #
    # For now we avoid the unwanted SELECTS by providing a ham + spam count
    # which uses the counter cache.
    if post.accepts_comments? || post.comments_count > 0
      link_to comment_count(post.comments_count), {
        :controller => 'posts',
        :action => 'show',
        :id => post.to_param,
        :anchor => 'comments',
        :protocol => 'https'
      },
      :class => 'comments_link'
    else
      ''
    end
  end
end
