class PostSweeper < ActionController::Caching::Sweeper
  observe Post

  # routing helpers (articles_path etc) _might_ not work without this include (behaviour seems erratic)
  include ActionController::UrlWriter

  def after_destroy post
    expire_cache
  end

  def after_save post
    expire_cache
  end

  def expire_cache
    # TODO: add per-post feeds as well (for monitoring comments)
    # for now we're only sweeping the main atom feed
    expire_page(posts_path + '.atom')
  end

  # on-demand cache expiration from rake, RSpec etc
  def self.expire_all
    new.expire_cache
  end
end # class PostSweeper
