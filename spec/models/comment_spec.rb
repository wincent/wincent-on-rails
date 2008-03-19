require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  it 'should be valid' do
    create_comment.should be_valid
  end
end
