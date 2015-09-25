class ProductsController < ApplicationController
  before_filter :get_product, only: :show
  before_filter :get_page, only: :show

  def index
    @products = Product.front_page.group_by(&:category)
  end

  def show
    render
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
      @page = @product.pages.find_by_permalink params[:page_id]
      if @page.nil?
        # can't rely on normal "record_not_found" logic here because we want a custom flash
        flash[:error] = 'Requested page not found'
        redirect_to @product
      end
    else
      @page = @product.pages.where(front: true).first
    end
  end
end
