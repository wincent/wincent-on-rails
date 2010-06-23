require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Word do
  before(:each) do
    @word = Word.new
  end

  it "should be valid" do
    @word.should be_valid
  end
end
