class ArticleSweeper < ActionController::Caching::Sweeper
  observe Article

  # routing helpers (articles_path etc) _might_ not work without this include (behaviour seems erratic)
  include ActionController::UrlWriter

  def after_destroy article
    expire_cache
  end

  def after_save article
    expire_cache
  end

  def expire_cache
    expire_page(articles_path + '.atom')
  end
end # class ArticleSweeper
