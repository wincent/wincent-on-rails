module PostsHelper
  def excerpt_html
    preserve @post.excerpt.w
  end

  def body_html
    preserve(@post.body ? @post.body.w : '')
  end

  def excerpt_and_body_html
    text = [(@post.excerpt || ''), (@post.body || '')].join("\n\n")
    preserve(text.w)
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
    # form ID will either be "new_post" or "edit_post_1", "edit_post_2" etc
    #form_id = "#{request.parameters['action']}_post"
    #(form_id << "_#{@post.id}") if (@post && @post.id)
    # for some reason if I use Form.serialize at all Rails adds _method='put' to my query as a hidden param
    {
      :url => blog_index_path,
      :method => 'post',
      :update => 'preview',
      #:with => "Form.serialize('#{form_id}')",
      #:with => "form=Form.serialize('#{form_id}')",
      :with => "'title=' + encodeURIComponent($('post_title').value) + '&excerpt=' + encodeURIComponent($('post_excerpt').value) + '&body=' + encodeURIComponent($('post_body').value)",
      :before => "Element.show('spinner')",
      :complete => "Element.hide('spinner')"
    }
  end

  def comment_count number
    pluralizing_count number, 'comment'
  end

  def comments_link post
    if post.accepts_comments? || post.comments.ham_count > 0
      link_to comment_count(post.comments.ham_count),
        { :controller => 'posts', :action => 'show', :id => @post.to_param, :anchor => 'comments'},
        :class => 'comments_link'
    else
      ''
    end
  end
end
