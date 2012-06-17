class PostSweeper < ActionController::Caching::Sweeper
  observe Post

  extend  Sweeping
  include Sweeping

  # on-demand cache expiration from Rake (`rake cache:clear`), RSpec etc
  def self.expire_all
    safe_expire posts_path, :recurse => true  # /blog/*
    safe_expire posts_path('.atom')           # /blog.atom
  end

  def after_destroy(post)
    expire_cache post
  end

  def after_save(post)
    expire_cache post
  end

private

  def expire_cache(post)
    safe_expire posts_path('.atom') # /blog.atom
    safe_expire post_path(post)     # /blog/foo-bar.atom
  end
end # class PostSweeper
