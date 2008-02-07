require File.dirname(__FILE__) + '/../spec_helper'

describe Status do
  it 'should be valid' do
    create_status.should be_valid
  end
end
