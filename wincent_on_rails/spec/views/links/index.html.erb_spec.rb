require File.dirname(__FILE__) + '/../../spec_helper'

describe "/links/index.html.erb" do
  include LinksHelper
  
  before(:each) do
    link_98 = mock_model(Link)
    link_98.should_receive(:uri).and_return("MyString")
    link_98.should_receive(:permalink).and_return("MyString")
    link_98.should_receive(:click_count).and_return("1")
    link_99 = mock_model(Link)
    link_99.should_receive(:uri).and_return("MyString")
    link_99.should_receive(:permalink).and_return("MyString")
    link_99.should_receive(:click_count).and_return("1")

    assigns[:links] = [link_98, link_99]
  end

  it "should render list of links" do
    render "/links/index.html.erb"
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "1", 2)
  end
end

