module PagesHelper
  def button_to_destroy_page page
    button_to 'destroy', product_page_path(page.product, page),
      :confirm => 'Are you sure?', :method => :delete,
      :class => 'destructive'
  end
end
