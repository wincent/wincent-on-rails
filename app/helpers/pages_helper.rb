module PagesHelper
  def button_to_destroy_page page
    button_to_destroy_model page, product_page_path(page.product, page)
  end
end
