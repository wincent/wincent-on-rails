require 'spec_helper'

describe ProductsHelper do
  describe '#product_page_title' do
    before do
      @product = Product.make! :name => 'foo'
      @page = Page.make! :title => 'bar', :product => @product
    end

    context 'product only, no page' do
      it 'returns the product name' do
        product_page_title(@product, nil).should == 'foo'
      end
    end

    context 'product and page' do
      it 'joins product name and page title' do
        product_page_title(@product, @page).should == 'foo: bar'
      end
    end
  end
end
