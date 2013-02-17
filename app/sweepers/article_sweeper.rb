class ArticleSweeper < ActionController::Caching::Sweeper
  observe Article

  extend  Sweeping
  include Sweeping

  # on-demand cache expiration from Rake, (`rake cache:clear`),  RSpec etc
  def self.expire_all
    safe_expire articles_path, :recurse => true # /wiki/*
    safe_expire articles_path('.atom')          # /wiki.atom
  end

  def after_destroy(article)
    expire_cache article
  end

  def after_save(article)
    expire_cache article
  end

private

  def expire_cache(article)
    safe_expire articles_path('.atom')  # /wiki.atom
    safe_expire article_path(article)   # /wiki/foo.atom
  end
end # class ArticleSweeper
