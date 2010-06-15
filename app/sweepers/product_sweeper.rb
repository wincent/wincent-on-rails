class ProductSweeper < ActionController::Caching::Sweeper
  observe Product

  # Rails BUG: https://rails.lighthouseapp.com/projects/8994/tickets/4868
  include Rails.application.routes.url_helpers

  # not yet required
  #def after_destroy product
  #  expire_cache product
  #end

  def after_save product
    expire_cache product
  end

  def expire_cache product
    expire_page(product_path(product) + '.html')  # products/foo.html
    #expire_page(product_path(product) + '.atom')  # products/foo.atom
    expire_page(products_path + '.html')          # products.html
    #expire_page(products_path + '.atom')          # products.atom

    # now products/foo/about.html, products/foo/buy.html etc
    page_dir = ActionController::Base.send(:page_cache_directory) + product_path(product)
    if File.exist? page_dir
      File.delete(*Dir["#{page_dir}/*.html"])
    end
  end

  # on-demand cache expiration from rake (rake cache:clear)
  def self.expire_all
    # see the notes in the IssueSweeper for full explanation of why we do it this way
    relative_path   = instance.send :products_path
    index_path      = ActionController::Base.send(:page_cache_directory) + relative_path

    # products.atom, products.html
    # products/foo.atom, products/foo.html etc
    # products/foo/about.html, products/foo/buy.html etc
    FileUtils.rm_rf(Dir["#{index_path}*"])
  end
end
