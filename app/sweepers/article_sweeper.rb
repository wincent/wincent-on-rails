class ArticleSweeper < ActionController::Caching::Sweeper
  observe Article

  def after_destroy article
    expire_cache article
  end

  def after_save article
    expire_cache article
  end

  def expire_cache article
    expire_page(articles_path + '.atom')
    expire_page(article_path(article) + '.atom')
  end

  # on-demand cache expiration from rake, RSpec etc
  def self.expire_all
    # see the notes in the IssueSweeper for full explanation of why we do it this way
    Article.all.each do |article|
      relative_path = instance.send(:article_path, article) + '.atom'
      absolute_path = ActionController::Base.send(:page_cache_path, relative_path)
      File.delete absolute_path if File.exist?(absolute_path)
    end
    relative_path = instance.send(:articles_path) + '.atom'
    absolute_path = ActionController::Base.send(:page_cache_path, relative_path)
    File.delete absolute_path if File.exist?(absolute_path)
  end
end # class ArticleSweeper
