require 'spec_helper'

describe Word do
  before(:each) do
    @word = Word.new
  end

  it "should be valid" do
    expect(@word).to be_valid
  end
end
