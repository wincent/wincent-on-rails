module TagsHelper
  def taggable_link model
    case model
    when Article
      link_to model.title, wiki_path(model)
    when Post
      link_to model.title, blog_path(model)
    else
      raise 'not yet implemented'
    end
  end

  def search_page_title
    if @tags
      page_title "Tags: #{(@tags[:found].collect {|t| t.name}).join ', '}"
    else
      page_title "Tag search"
    end
  end
end
