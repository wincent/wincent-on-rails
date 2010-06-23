require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe ProductsController do
  it_should_behave_like 'ApplicationController protected methods'
  it_should_behave_like 'ApplicationController parameter filtering'
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
      Product.should_receive(:front_page)
      do_get
    end

    it 'should assign found products for the view' do
      Product.stub!(:front_page).and_return(@products)
      do_get
      assigns[:products].should == @products
    end

    it 'should render the index template' do
      do_get
      response.should render_template('index')
    end
  end
end
