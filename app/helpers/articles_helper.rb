module ArticlesHelper
  def body_html
    @article ? @article.body.w : ''
  end

  def link_to_update_preview
    link_to_remote 'update', common_options, :class => 'update_link'
  end

  def observe_body
    observe_field 'article_body', common_options.merge({:frequency => 30.0})
  end

  def common_options
    {
      :url => wiki_index_path,
      :method => 'post',
      :update => 'preview',
      :with => "'body=' + encodeURIComponent($('article_body').value)",
      :before => "Element.show('spinner')",
      :complete => "Element.hide('spinner')"
    }
  end
end
