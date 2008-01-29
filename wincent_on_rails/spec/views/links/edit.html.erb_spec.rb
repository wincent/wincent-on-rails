require File.dirname(__FILE__) + '/../../spec_helper'

describe "/links/edit.html.erb" do
  include LinksHelper
  
  before do
    @link = mock_model(Link)
    @link.stub!(:uri).and_return("MyString")
    @link.stub!(:permalink).and_return("MyString")
    @link.stub!(:click_count).and_return("1")
    assigns[:link] = @link
  end

  it "should render edit form" do
    render "/links/edit.html.erb"
    
    response.should have_tag("form[action=#{link_path(@link)}][method=post]") do
      with_tag('input#link_uri[name=?]', "link[uri]")
      with_tag('input#link_permalink[name=?]', "link[permalink]")
      with_tag('input#link_click_count[name=?]', "link[click_count]")
    end
  end
end


