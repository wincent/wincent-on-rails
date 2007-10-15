require File.dirname(__FILE__) + '/../spec_helper'

describe Revision do
  before(:each) do
    @revision = Revision.new
  end

  it "should be valid" do
    @revision.should be_valid
  end
end
