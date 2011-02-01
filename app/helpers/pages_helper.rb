module PagesHelper
  def button_to_destroy_page page, options = {}
    button_to_destroy_model product_page_path(page.product, page), options
  end
end
