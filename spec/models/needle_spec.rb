require File.dirname(__FILE__) + '/../spec_helper'

describe Needle do
  before(:each) do
    @needle = Needle.new
  end

  it "should be valid" do
    @needle.should be_valid
  end
end
