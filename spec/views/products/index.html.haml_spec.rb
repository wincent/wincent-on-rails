require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'products/index' do
  before do
    Product.make!  :name => 'Synergy',
                   :description => '<p>An iTunes controller</p>',
                   :category => 'Consumer',
                   :hide_from_front_page => false
    Product.make!  :name => 'Synergy Advance',
                   :description => '<p>An improved iTunes accessory</p>',
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

  it 'shows description HTML' do
    rendered.should have_selector('p', :content => 'An iTunes controller')
    rendered.should have_selector('p', :content => 'An improved iTunes accessory')
  end
end
