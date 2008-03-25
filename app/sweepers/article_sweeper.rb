class ArticleSweeper < ActionController::Caching::Sweeper
  observe Article

  def after_destroy article
    expire_cache
  end

  def after_save article
    expire_cache
  end

  def expire_cache
    expire_page(wiki_index_path + '.atom')
  end
end # class TopicSweeper
