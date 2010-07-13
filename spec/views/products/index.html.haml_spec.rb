require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'products/index' do
  before do
    Product.make!  :name => 'Synergy',
                   :description => 'An iTunes controller',
                   :category => 'Consumer',
                   :hide_from_front_page => false
    Product.make!  :name => 'Synergy Advance',
                   :description => 'An improved iTunes accessory',
                   :category => 'Consumer',
                   :hide_from_front_page => false
    @products = Product.categorized
    render
  end

  it 'renders list of products' do
    rendered.should have_selector('h3', :content => 'Synergy')
    rendered.should have_selector('h3', :content => 'Synergy Advance')
  end

  it 'shows category headings' do
    rendered.should have_selector('h2', :content => 'Consumer products')
  end
end
