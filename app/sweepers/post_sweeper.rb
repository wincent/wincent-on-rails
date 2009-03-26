class PostSweeper < ActionController::Caching::Sweeper
  observe Post

  # routing helpers (articles_path etc) _might_ not work without this include (behaviour seems erratic)
  include ActionController::UrlWriter

  def after_destroy post
    expire_cache post
  end

  def after_save post
    expire_cache post
  end

  def expire_cache post
    expire_page(posts_path + '.atom')
    expire_page(post_path(post) + '.atom')
  end

  # on-demand cache expiration from rake, RSpec etc
  def self.expire_all
    # see the notes in the IssueSweeper for full explanation of why we do it this way
    Post.all.each do |post|
      relative_path = instance.send(:post_path, post) + '.atom'
      absolute_path = ActionController::Base.send(:page_cache_path, relative_path)
      File.delete absolute_path if File.exist?(absolute_path)
    end
    relative_path = instance.send(:posts_path) + '.atom'

    # TODO: consider moving this into a helper method declared in the superclass
    absolute_path = ActionController::Base.send(:page_cache_path, relative_path)
    File.delete absolute_path if File.exist?(absolute_path)
  end
end # class PostSweeper
