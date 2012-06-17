class ProductSweeper < ActionController::Caching::Sweeper
  observe Product

  extend  Sweeping
  include Sweeping

  # on-demand cache expiration from Rake (`rake cache:clear`), RSpec etc
  def self.expire_all
    safe_expire products_path, :recurse => true   # /products/**/*
    safe_expire products_path('.html')            # /products.html
    safe_expire(Rails.root + 'public/index.html') # / (products#index)
  end

  def after_destroy(product)
    expire_cache product
  end

  def after_save(product)
    expire_cache product
  end

private

  def expire_cache(product)
    safe_expire product_path(product, '.html')    # /products/foo.html
    safe_expire products_path('.html')            # /products.html
    safe_expire(Rails.root + 'public/index.html') # / (products#index)

    # /products/foo/about.html, /products/foo/buy.html etc
    safe_expire product_path(product), :recurse => true
  end
end
