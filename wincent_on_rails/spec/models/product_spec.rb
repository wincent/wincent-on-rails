require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Product, 'validating the name' do
  it 'should require it to be present' do
    new_product(:name => nil).should fail_validation_for(:name)
  end

  it 'should require it to be unique' do
    name = String.random
    create_product(:name => name).should be_valid
    new_product(:name => name).should fail_validation_for(:name)
  end
end
