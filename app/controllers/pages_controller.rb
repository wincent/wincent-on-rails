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
  before_filter :get_page, :only => [:edit, :update]

  def new
    @page = @product.pages.build
  end

  def create
    @page = @product.pages.build params[:page]
    if @page.save
      flash[:notice] = 'Successfully created new page'
      redirect_to embedded_product_page_path(@product, :page_id => @page.to_param)
    else
      flash[:error] = 'Failed to create new page'
      render :action => 'new'
    end
  end

private

  def get_product
    @product = Product.find_by_permalink! params[:product_id]
  end

  def get_page
    @page = @product.pages.find_by_permalink! params[:id]
  end
end
