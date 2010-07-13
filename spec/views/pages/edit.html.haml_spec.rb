require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'pages/edit' do
  before do
    @product = Product.make!
    @page = Page.make! :product_id => @product.id
  end

  it "renders the edit page form" do
    render

    rendered.should have_selector('form[method=post]', :action => product_page_path(@product, @page)) do |form|
      form.should have_selector('input#page_title', :name => 'page[title]')
      form.should have_selector('input#page_permalink', :name => 'page[permalink]')
      form.should have_selector('textarea#page_body', :name => 'page[body]')
      form.should have_selector('input#page_front', :name => 'page[front]')
    end
  end
end
