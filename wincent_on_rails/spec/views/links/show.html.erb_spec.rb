require File.dirname(__FILE__) + '/../../spec_helper'

describe "/links/show.html.erb" do
  include LinksHelper
  
  before(:each) do
    @link = mock_model(Link)
    @link.stub!(:uri).and_return("MyString")
    @link.stub!(:permalink).and_return("MyString")
    @link.stub!(:click_count).and_return("1")

    assigns[:link] = @link
  end

  it "should render attributes in <p>" do
    render "/links/show.html.erb"
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/1/)
  end
end

