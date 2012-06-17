# At the moment this is intimately bound to the Product model, and will need to
# be modified if we ever allow stand-alone pages.
class PageSweeper < ActionController::Caching::Sweeper
  observe Page

  extend  Sweeping
  include Sweeping

  # on-demand cache expiration from Rake (`rake cache:clear`), RSpec etc
  def self.expire_all
    safe_expire products_path, :recurse => true   # /products/**/*
  end

  def after_destroy(page)
    expire_cache page
  end

  def after_save(page)
    expire_cache page
  end

private

  def expire_cache(page)
    return unless product = page.product
    safe_expire product_path(product, '.html')   # /products/foo.html

    # /products/foo/about.html, /products/foo/buy/html etc
    safe_expire product_path(product), :recurse => true
  end
end
