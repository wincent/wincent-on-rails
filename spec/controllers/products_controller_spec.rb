require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/application_controller_spec'

describe ProductsController do
  it_should_behave_like 'ApplicationController'
end

describe ProductsController, 'index action' do
  before do
    @products = [mock_model(Product)]
  end

  def do_get
    get :index, :protocol => 'https'
  end

  # until all (or at least most) products are set up will just redirect
  it 'should redirect to the old site' do
    do_get
    response.should redirect_to('http://wincent.com/a/products/')
  end

  # temporarily disabled while redirect is in effect
  if false
    it 'should be successful' do
      do_get
      response.should be_success
    end

    it 'should find all products' do
      Product.should_receive(:categorized_products)
      do_get
    end

    it 'should assign found products for the view' do
      Product.stub!(:categorized_products).and_return(@products)
      do_get
      assigns[:products].should == @products
    end

    it 'should render the index template' do
      do_get
      response.should render_template('index')
    end
  end
end
