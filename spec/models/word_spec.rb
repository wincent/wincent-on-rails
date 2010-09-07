require 'spec_helper'

describe Word do
  before(:each) do
    @word = Word.new
  end

  it "should be valid" do
    @word.should be_valid
  end
end
