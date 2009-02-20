require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Message do
  it 'should treat all fields as optional' do
    Message.create.should be_valid
  end
end
