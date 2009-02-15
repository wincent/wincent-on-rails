# Rails 2.3.0 BUG: uninitialized constant ActionController::Caching::Sweeper
# only occurs in development environment (where cache_classes is false)
# http://groups.google.com/group/rubyonrails-talk/t/323ff7ec2d95ee32
begin
  ActionController::Caching::Sweeper
rescue NameError
  require 'rails/actionpack/lib/action_controller/caching/sweeping'
end

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
    new.expire_cache
  end
end # class ArticleSweeper
