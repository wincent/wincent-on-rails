require File.dirname(__FILE__) + '/../spec_helper'

describe Locale do
  before(:each) do
    @locale = Locale.new
  end

  it "should be valid" do
    @locale.should be_valid
  end
end
