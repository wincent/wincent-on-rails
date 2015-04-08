require 'spec_helper'

describe 'pages/edit' do
  before do
    @product = Product.make!
    @page = Page.make! :product_id => @product.id
  end

  it "renders the edit page form" do
    render

    within("form.edit_page[method=post][action='#{product_page_path(@product, @page)}']") do |form|
      expect(form).to have_css('input#page_title[name="page[title]"]')
      expect(form).to have_css('input#page_permalink[name="page[permalink]"]')
      expect(form).to have_css('textarea#page_body[name="page[body]"]')
      expect(form).to have_css('input#page_front[name="page[front]"]')
    end
  end
end
