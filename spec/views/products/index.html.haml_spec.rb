require File.dirname(__FILE__) + '/../../spec_helper'

describe '/products/index.html.haml' do
  include ProductsHelper

  before do
    product_1 = mock_model(Product)
    product_1.should_receive(:name).and_return('Synergy')
    product_1.should_receive(:icon_path).at_least(1).and_return(nil)
    product_1.should_receive(:description).at_least(1).and_return('An iTunes controller')
    product_2 = mock_model(Product)
    product_2.should_receive(:name).and_return('Synergy Advance')
    product_2.should_receive(:icon_path).at_least(1).and_return('/system/products/icons/synergy-advance.png')
    product_2.should_receive(:description).at_least(1).and_return('An improved iTunes accessory')
    assigns[:products] = [product_1, product_2]
    render '/products/index.html.haml'
  end

  it 'should render list of products' do
    response.should have_tag('h2', 'Synergy')
    response.should have_tag('h2', 'Synergy Advance')
  end
end
