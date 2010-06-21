require File.expand_path('../acceptance_helper', File.dirname(__FILE__))

feature 'Products index' do
  scenario 'visiting the index' do
    p1 = Product.make!
    p2 = Product.make!
    visit '/products'
    page.should have_content(p1.name)
    page.should have_content(p2.name)
  end

  scenario 'visiting the index with a hidden product' do
    p1 = Product.make! :hide_from_front_page => true
    p2 = Product.make! :hide_from_front_page => false
    visit '/products'
    page.should_not have_content(p1.name)
    page.should have_content(p2.name)
  end
end
