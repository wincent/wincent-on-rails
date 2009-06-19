module ArticlesHelper
  def title_and_body_html article
    text = []
    text << (article.title.blank? ? '' : "= #{article.title} =")
    text << article.body
    text.join("\n\n").w :base_heading_level => 2
  end
end
