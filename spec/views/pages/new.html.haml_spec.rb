require 'spec_helper'

describe 'pages/new' do
  before do
    @product = Product.make!
    @page = Page.make :product_id => @product.id
  end

  it 'renders new page form' do
    render

    rendered.should have_css("form[method=post]", :action => product_pages_path(@product)) do |form|
      form.should have_css('input#page_title', :name => 'page[title]')
      form.should have_css('input#page_permalink', :name => 'page[permalink]')
      form.should have_css('textarea#page_body', :name => 'page[body]')
      form.should have_css('input#page_front', :name => 'page[front]')
    end
  end
end
