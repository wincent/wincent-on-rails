# Rails 2.3.0 BUG: uninitialized constant ActionController::Caching::Sweeper
# only occurs in development environment (where cache_classes is false)
begin
  ActionController::Caching::Sweeper
rescue NameError
  require 'rails/actionpack/lib/action_controller/caching/sweeping'
end

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
end # class PostSweeper
