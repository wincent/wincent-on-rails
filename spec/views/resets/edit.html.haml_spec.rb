require File.dirname(__FILE__) + '/../../spec_helper'

describe "/resets/edit.html.erb" do
  include ResetsHelper
  
  before do
    @reset = mock_model(Reset)
    @reset.stub!(:user_id).and_return("1")
    @reset.stub!(:secret).and_return("MyString")
    @reset.stub!(:cutoff).and_return(Time.now)
    @reset.stub!(:completed_at).and_return(Time.now)
    assigns[:reset] = @reset
  end

  it "should render edit form" do
    render "/resets/edit.html.erb"
    
    response.should have_tag("form[action=#{reset_path(@reset)}][method=post]") do
      with_tag('input#reset_secret[name=?]', "reset[secret]")
    end
  end
end


