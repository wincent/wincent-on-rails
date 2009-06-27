class ProductsController < ApplicationController
  before_filter :require_admin, :except => [ :index, :show ]
  before_filter :get_product, :only => [ :edit, :show, :update ]

  def index
    @products = Product.find :all
  end

  def show
    render
    # TODO: Atom feed will be for product update notices
  end

  # admin-only
  def edit
    render
  end

  # admin-only
  def new
    @product = Product.new
  end

  # admin-only
  def create
    @product = Product.create params[:product]
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
end
