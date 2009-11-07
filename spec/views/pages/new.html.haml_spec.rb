require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/pages/new.html.haml" do
  include PagesHelper

  before(:each) do
    assigns[:product] = @product = create_product
    assigns[:page] = new_page :product_id => @product.id
  end

  it "renders new page form" do
    render

    response.should have_tag("form[action=?][method=post]", product_pages_path(@product)) do
      with_tag("input#page_title[name=?]", "page[title]")
      with_tag("input#page_permalink[name=?]", "page[permalink]")
      with_tag("textarea#page_body[name=?]", "page[body]")
      with_tag("input#page_front[name=?]", "page[front]")
    end
  end
end
