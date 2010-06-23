require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Email do
  it 'should be valid' do
    create_email.should be_valid
  end
end
