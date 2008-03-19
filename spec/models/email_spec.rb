require File.dirname(__FILE__) + '/../spec_helper'

describe Email do
  it 'should be valid' do
    create_email.should be_valid
  end
end
