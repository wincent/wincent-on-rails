module PostsHelper
  def excerpt_html
    @post.excerpt.w
  end

  def body_html
    @post.body ? @post.body.w : ''
  end

  def excerpt_and_body_html
    text = [(@post.excerpt || ''), (@post.body || '')].join("\n\n")
    preserve(text.w)
  end

  def link_to_update_preview
    link_to_remote 'update', common_options
  end

  def observe_excerpt
    observe_field 'post_body', common_options.merge({:frequency => 30.0})
  end

  def observe_body
    observe_field 'post_body', common_options.merge({:frequency => 30.0})
  end

  def common_options
    # form ID will either be "new_post" or "edit_post_1", "edit_post_2" etc
    form_id = "#{request.parameters['action']}_post"
    (form_id << "_#{@post.id}") if (@post && @post.id)
    {
      :url => blog_index_path,
      :method => 'post',
      :update => 'preview',
      :with => "Form.serialize('#{form_id}')",
      :before => "Element.show('spinner')",
      :complete => "Element.hide('spinner')"
    }
  end
end
