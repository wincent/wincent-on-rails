require File.dirname(__FILE__) + '/../spec_helper'

describe Issue do
  before(:each) do
    @issue = Issue.new
  end

  it "should be valid" do
    @issue.should be_valid
  end
end
