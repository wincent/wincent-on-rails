module ArticlesHelper
  def body_html
    # NOTE: adding a "w" method to the Nil class would make this helper a little bit redundant (@article.body.w would work)
    body = @article.body
    body.nil? ? '': body.w
  end

  def link_to_update_preview
    link_to_remote 'update', common_options, :class => 'update_link'
  end

  def observe_body
    observe_field 'article_body', common_options.merge({:frequency => 30.0})
  end

  def common_options
    {
      :url => articles_path,
      :method => 'post',
      :update => 'preview',
      :with => "'body=' + encodeURIComponent($('article_body').value)",
      :before => "Element.show('spinner')",
      :complete => "Element.hide('spinner')"
    }
  end
end
