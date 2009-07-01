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
  before_filter :get_page, :only => [:destroy, :edit, :update]
  cache_sweeper :page_sweeper, :only => [:create, :destroy, :update]

  def new
    @page = @product.pages.build
  end

  def create
    @page = @product.pages.build params[:page]
    if @page.save
      flash[:notice] = 'Successfully created new page'
      redirect_to embedded_product_page_path(@product, @page)
    else
      flash[:error] = 'Failed to create new page'
      render :action => 'new'
    end
  end

  def edit
    render
  end

  def update
    if @page.update_attributes params[:page]
      flash[:notice] = 'Successfully updated page'
      redirect_to embedded_product_page_path(@product, @page)
    else
      # special case: form URL will be wrong here if the user edited the permalink
      @page.permalink = params[:id]
      flash[:error] = 'Failed to update page'
      render :action => 'edit'
    end
  end

   def destroy
     # TODO: make this undoable
     @page.destroy
     respond_to do |format|
       format.js { render :json => {}.to_json }
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
