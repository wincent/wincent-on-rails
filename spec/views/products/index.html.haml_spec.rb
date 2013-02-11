require 'spec_helper'

describe 'products/index' do
  before do
    Product.make!  name:                  'Synergy',
                   description:           '<p>An iTunes controller</p>',
                   category:              'Consumer',
                   hide_from_front_page:  false
    Product.make!  name:                  'Synergy Advance',
                   description:           '<p>An improved iTunes accessory</p>',
                   category:              'Consumer',
                   hide_from_front_page:  false
    @products = Product.categorized
    render
  end

  it 'renders list of products' do
    rendered.should have_css('h3', text: 'Synergy')
    rendered.should have_css('h3', text: 'Synergy Advance')
  end

  it 'shows category headings' do
    rendered.should have_css('h2', text: 'Consumer products')
  end

  it 'shows description HTML' do
    rendered.should have_css('p', text: 'An iTunes controller')
    rendered.should have_css('p', text: 'An improved iTunes accessory')
  end
end
