class ProductsController < ApplicationController
  before_filter :require_admin, :except => [ :index, :show ]

  def index
    @products = Product.find :all
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.create params[:product]
  end
end
