module ProductsHelper
  # for now only called by products#show
  def product_page_title product, page
    title = product.name
    title << ": #{page.title}" if page
  end
end
