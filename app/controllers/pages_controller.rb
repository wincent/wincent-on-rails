# For now normal users will only ever view pages in the context of their
# parent products, so this is an admin-only controller for the purposes of
# creating and editing pages.
#
# In the future if the need arises to create independent pages which
# aren't associated with any specific product then this controller can be
# modified to handle that. (And if that does happen, the Page model itself
# will probably be modified to serve as a container for both HTML and
# wikitext markup.)
class PagesController < ApplicationController
  before_filter :require_admin
  before_filter :get_product
  before_filter :get_page, :only => :edit

  def new
    @page = @product.pages.build
  end

private

  def get_product
    @product = Product.find_by_permalink! params[:product_id]
  end
end
