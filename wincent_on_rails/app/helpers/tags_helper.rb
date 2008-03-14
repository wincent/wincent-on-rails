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

  def tag_names
    if @tags
      "#{(@tags[:found].collect(&:name)).join ', '}"
    else
      ''
    end
  end

  def search_page_title
    if @tags
      page_title "Tags: #{tag_names}"
    else
      page_title "Tag search"
    end
  end

  def taggables_search_summary
    count = @taggables.keys.inject(0) { |acc, value| acc += @taggables[value].length }
    "#{item_count(count)} tagged with #{tag_names}"
  end
end
