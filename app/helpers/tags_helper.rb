module TagsHelper
  def taggable_link model
    case model
    when Issue
      link_to model.summary, model
    when Snippet
      link_to snippet_title(model), model
    when Tweet
      link_to tweet_title(model), model
    else # Article, Post, Topic
      link_to model.title, model
    end
  end

  def tag_names tags
    if tags
      "#{(tags[:found].collect(&:name)).join ', '}"
    else
      ''
    end
  end

  def search_page_title tags
    if tags
      "Tags: #{tag_names(tags)}"
    else
      'Tag search'
    end
  end

  def taggables_search_summary tags, taggables
    count = taggables.inject(0) { |acc, value| acc += value.taggables.length }
    if tag_names(tags).empty?
      '0 items tagged with specified tags'
    else
      "#{item_count(count)} tagged with #{tag_names(tags)}"
    end
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
