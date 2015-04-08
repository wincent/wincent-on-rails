require 'spec_helper'

describe ProductsController do
  it_should_behave_like 'ApplicationController subclass'

  describe '#index' do
    before do
      @products = [ Product.make!(:category => 'Excellent') ]
    end

    it 'is successful' do
      get :index
      expect(response).to be_success
    end

    it 'finds all products' do
      mock(Product).front_page { @products }
      get :index
    end

    it 'assigns found products, grouped by category' do
      stub(Product).front_page { @products }
      get :index
      expect(assigns[:products]).to eq({ 'Excellent' => @products })
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template('index')
    end
  end
end
