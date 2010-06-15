# At the moment this is intimately bound to the Product model, and will need to
# be modified if we ever allow stand-alone pages.
class PageSweeper < ActionController::Caching::Sweeper
  observe Page

  # Rails BUG: https://rails.lighthouseapp.com/projects/8994/tickets/4868
  include Rails.application.routes.url_helpers

  def after_destroy page
    expire_cache page
  end

  def after_save page
    expire_cache page
  end

  def expire_cache page
    return unless product = page.product
    expire_page(product_path(product) + '.html')  # products/foo.html
    #expire_page(product_path(product) + '.atom')  # products/foo.atom

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

    # products/foo.atom, products/foo.html etc
    # products/foo/about.html, products/foo/buy.html etc
    FileUtils.rm_rf(Dir["#{index_path}/*"])
  end
end
