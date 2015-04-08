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
    expect(rendered).to have_css('h3', text: 'Synergy')
    expect(rendered).to have_css('h3', text: 'Synergy Advance')
  end

  it 'shows category headings' do
    expect(rendered).to have_css('h2', text: 'Consumer products')
  end

  it 'shows description HTML' do
    expect(rendered).to have_css('p', text: 'An iTunes controller')
    expect(rendered).to have_css('p', text: 'An improved iTunes accessory')
  end
end
