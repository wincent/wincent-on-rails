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
end
