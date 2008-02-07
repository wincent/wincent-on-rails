require File.dirname(__FILE__) + '/../spec_helper'

describe Translation do
  it 'should be valid' do
    create_translation.should be_valid
  end
end
