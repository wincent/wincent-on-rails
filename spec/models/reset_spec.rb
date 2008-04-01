require File.dirname(__FILE__) + '/../spec_helper'

describe Reset do
  before(:each) do
    @reset = Reset.new
  end

  it "should be valid" do
    @reset.should be_valid
  end
end
