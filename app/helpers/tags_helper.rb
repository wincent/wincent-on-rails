module TagsHelper
  def taggable_link model
    case model
    when Article
      link_to h(model.title), wiki_path(model)
    when Post
      link_to h(model.title), blog_path(model)
    when Topic
      # BUG: another "n + 1 SELECT" issue here
      # if we present a list of model tags, each model here does a model.forum, which means an additional database query for each
      # for now the workaround will be to simply avoid tagging forum topics!
      # but a long-term solution will need to be found,
      # most likely involving "pre-seeding" in some way
      link_to h(model.title), forum_topic_path(model.forum, model)
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
    count = @taggables.inject(0) { |acc, value| acc += value.taggables.length }
    "#{item_count(count)} tagged with #{tag_names}"
  end

  # make the search results a little more user-friendly
  # users shouldn't need to know the meaning of the internal model names
  # especially in cases like Article and Post
  # (which have totally different URL components, "wiki" and "blog" respectively)
  def taggable_name string
    string = string.downcase
    case string
    when 'article' : 'wiki article'
    when 'post' : 'blog post'
    else
      string
    end
  end
end
