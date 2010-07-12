require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe ProductsController do
  it_should_behave_like 'ApplicationController protected methods'
  it_should_behave_like 'ApplicationController parameter filtering'
end

describe ProductsController, '#index' do
  before do
    @products = [ Product.make! :category => 'Excellent' ]
  end

  it 'is successful' do
    get :index
    response.should be_success
  end

  it 'finds all products' do
    mock(Product).front_page { @products }
    get :index
  end

  it 'assigns found products, grouped by category' do
    stub(Product).front_page { @products }
    get :index
    assigns[:products].should == { 'Excellent' => @products }
  end

  it 'renders the index template' do
    get :index
    response.should render_template('index')
  end
end
