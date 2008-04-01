require File.dirname(__FILE__) + '/../../spec_helper'

describe "/resets/new.html.erb" do
  include ResetsHelper
  
  before(:each) do
    @reset = mock_model(Reset)
    @reset.stub!(:new_record?).and_return(true)
    @reset.stub!(:user_id).and_return("1")
    @reset.stub!(:secret).and_return("MyString")
    @reset.stub!(:cutoff).and_return(Time.now)
    @reset.stub!(:completed_at).and_return(Time.now)
    assigns[:reset] = @reset
  end

  it "should render new form" do
    render "/resets/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", resets_path) do
      with_tag("input#reset_secret[name=?]", "reset[secret]")
    end
  end
end


