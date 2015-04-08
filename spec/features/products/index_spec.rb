require 'spec_helper'

feature 'Products index' do
  scenario 'visiting the index' do
    p1 = Product.make!
    p2 = Product.make!
    visit '/products'
    expect(page).to have_content(p1.name)
    expect(page).to have_content(p2.name)
  end

  scenario 'visiting the index with a hidden product' do
    p1 = Product.make! :hide_from_front_page => true
    p2 = Product.make! :hide_from_front_page => false
    visit '/products'
    expect(page).not_to have_content(p1.name)
    expect(page).to have_content(p2.name)
  end
end
