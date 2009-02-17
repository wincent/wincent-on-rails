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
    # see the notes in the IssueSweeper for full explanation of why we do it this way
    relative_path = instance.send(:posts_path) + '.atom'
    absolute_path = ActionController::Base.send(:page_cache_path, relative_path)
    File.delete absolute_path if File.exist?(absolute_path)
  end
end # class PostSweeper
