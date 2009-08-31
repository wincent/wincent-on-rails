class ProductsController < ApplicationController
  before_filter :require_admin, :except => [ :index, :show ]
  before_filter :get_product, :only => [ :edit, :show, :update ]
  before_filter :get_page, :only => :show
  caches_page   :index, :show
  cache_sweeper :product_sweeper, :only => [ :create, :update ] # and later, :destroy

  def index
    # NOTE: currently only the Synergy product pages are ready
    #       and there is no sense in preparing the other product
    #       pages until those products are Snow Leopard-ready.
    #       So for now just disable the index action, making it
    #       redirect to the old product index.
    redirect_to 'http://wincent.com/a/products/'

    #@products = Product.categorized_products
    # TODO: Atom feed will be for product update notices (all products)
  end

  def show
    render
    # TODO: Atom feed will be for product update notices (one product only)
  end

  # admin-only
  def edit
    render
  end

  # admin-only
  def new
    @product = Product.new
  end

  # admin-only
  def create
    @product = Product.new params[:product]
    if @product.save
      flash[:notice] = 'Successfully created new product'
      redirect_to @product
    else
      flash[:error] = 'Failed to create new product'
      render :action => 'new'
    end
  end

  # admin-only
  def update
    if @product.update_attributes params[:product]
      flash[:notice] = 'Successfully updated'
      redirect_to @product
    else
      flash[:error] = 'Update failed'
      render :action => 'edit'
    end
  end

private

  def get_product
    @product = Product.find_by_permalink! params[:id]
  end

  def get_page
    if params[:page_id]
      @page = Page.find_by_permalink params[:page_id]
      if @page.nil?
        # can't rely on normal "record_not_found" logic here because we want a custom flash
        flash[:error] = 'Requested page not found'
        redirect_to @product
      end
    else
      @page = @product.pages.first :conditions => { :front => true }
    end
  end
end
