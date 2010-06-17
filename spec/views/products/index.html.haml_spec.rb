require File.dirname(__FILE__) + '/../../spec_helper'

describe '/products/index.html.haml' do
  include ProductsHelper

  before do
    create_product  :name => 'Synergy',
                    :description => 'An iTunes controller',
                    :category => 'Consumer',
                    :hide_from_front_page => false
    create_product  :name => 'Synergy Advance',
                    :description => 'An improved iTunes accessory',
                    :category => 'Consumer',
                    :hide_from_front_page => false
    assigns[:products] = Product.categorized
    render '/products/index.html.haml'
  end

  it 'should render list of products' do
    response.should have_tag('h3', 'Synergy')
    response.should have_tag('h3', 'Synergy Advance')
  end

  it 'should show category headings' do
    response.should have_tag('h2', 'Consumer products')
  end
end
