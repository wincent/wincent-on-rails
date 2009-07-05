module ProductsHelper
  # for now only called by products#show
  def product_page_title product, page
    if page
      title = "#{product.name}: #{page.title}"
    else
      title = product.name
    end
  end
end
