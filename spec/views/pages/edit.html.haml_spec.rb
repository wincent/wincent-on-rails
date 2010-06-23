require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe "/pages/edit.html.haml" do
  include PagesHelper

  before(:each) do
    assigns[:product] = @product = create_product
    assigns[:page] = @page = create_page(:product_id => @product.id)
  end

  it "renders the edit page form" do
    render

    response.should have_tag("form[action=#{product_page_path(@product, @page)}][method=post]") do
      with_tag('input#page_title[name=?]', "page[title]")
      with_tag('input#page_permalink[name=?]', "page[permalink]")
      with_tag('textarea#page_body[name=?]', "page[body]")
      with_tag('input#page_front[name=?]', "page[front]")
    end
  end
end
