module PostsHelper
  def excerpt_html
    @post.excerpt.w
  end

  def body_html
    @post.body ? @post.body.w : ''
  end

  def excerpt_and_body_html
    text = [(@post.excerpt || ''), (@post.body || '')].join("\n\n")
    text.w
  end

  def link_to_update_preview
    link_to_remote 'update', common_options, :class => 'update_link'
  end

  def observe_excerpt
    observe_field 'post_excerpt', common_options.merge({:frequency => 30.0})
  end

  def observe_body
    observe_field 'post_body', common_options.merge({:frequency => 30.0})
  end

  def common_options
    {
      :url => posts_url,
      :method => 'post',
      :update => 'preview',
      :with => "'title=' + encodeURIComponent($('post_title').value) + '&excerpt=' + encodeURIComponent($('post_excerpt').value) + '&body=' + encodeURIComponent($('post_body').value)",
      :before => "Element.show('spinner')",
      :complete => "Element.hide('spinner')"
    }
  end

  def comment_count number
    pluralizing_count number, 'comment'
  end

  def comments_link post
    # NOTE: the problem with this method was that it was causing an "n +  1" SELECT problem in the index action
    # basically, calling "ham_count" unavoidably provokes a database query for each post;
    # the counter_cache is useless (and unused) in this case
    #
    # Previously, the code looked like this:
    #
    #   if post.accepts_comments? || post.comments.ham_count > 0
    #     link_to comment_count(post.comments.ham_count) ...
    #
    # For now we avoid the unwanted SELECTS by providing a ham + spam count which uses the counter cache
    if post.accepts_comments? || post.comments_count > 0
       link_to comment_count(post.comments_count),
        { :controller => 'posts', :action => 'show', :id => @post.to_param, :anchor => 'comments'},
        :class => 'comments_link'
    else
      ''
    end
  end
end
