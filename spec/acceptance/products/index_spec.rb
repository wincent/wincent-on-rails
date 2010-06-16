require File.expand_path('../acceptance_helper', File.dirname(__FILE__))

feature 'Products index' do
  scenario 'visiting the index' do
    p1 = Product.make!
    p2 = Product.make!
    visit '/products'
    page.should have_content(p1.name)
    page.should have_content(p2.name)
  end
end
