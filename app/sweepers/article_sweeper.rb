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

  # on-demand cache expiration from rake, RSpec etc
  def self.expire_all
    # see the notes in the IssueSweeper for full explanation of why we do it this way
    relative_path = instance.send(:articles_path) + '.atom'
    absolute_path = ActionController::Base.send(:page_cache_path, relative_path)
    File.delete absolute_path if File.exist?(absolute_path)
  end
end # class ArticleSweeper
