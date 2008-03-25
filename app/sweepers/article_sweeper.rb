class ArticleSweeper < ActionController::Caching::Sweeper
  observe Article

  def after_destroy article
    expire_cache
  end

  def after_save article
    expire_cache
  end

  def expire_cache
    # note that the html index doesn't get updated whenever tags change, as the top tags should change only infrequently
    #expire_page(wiki_index_path) # not currently used (caching to wiki.html would break pagination)
    expire_page(wiki_index_path + '.atom')
  end
end # class TopicSweeper
