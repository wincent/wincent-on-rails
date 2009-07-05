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

describe Product, 'validating the permalink' do
  it 'should require it to be present' do
    new_product(:permalink => nil).should fail_validation_for(:permalink)
  end

  it 'should require it to be unique' do
    permalink = String.random
    create_product(:permalink => permalink).should be_valid
    new_product(:permalink => permalink).should fail_validation_for(:permalink)
  end
end

describe Product, 'validating the bundle identifier' do
  it 'should not require it to be present' do
    product = create_product(:bundle_identifier => nil)
    product.should_not fail_validation_for(:bundle_identifier)
  end

  it 'should require it to be unique ' do
    bundle_id = "com.wincent.#{String.random}"
    create_product(:bundle_identifier => bundle_id).should be_valid
    product = new_product(:bundle_identifier => bundle_id)
    product.should fail_validation_for(:bundle_identifier)
  end

  it 'should permit multiple products with no bundle identifier' do
    2.times { create_product(:bundle_identifier => nil).should be_valid }
    2.times { create_product(:bundle_identifier => '').should be_valid }
  end
end

describe Product, 'default scope' do
  it 'should return products in category order by default' do
    c1 = create_product :category => 'consumer', :position => 10
    s1 = create_product :category => 'server', :position => 3
    d1 = create_product :category => 'developer', :position => 6
    Product.all.should == [c1, d1, s1]
  end

  it 'should return products in position order within each category' do
    c1 = create_product :category => 'consumer', :position => 10
    c2 = create_product :category => 'consumer', :position => 15
    c3 = create_product :category => 'consumer', :position => 1
    s1 = create_product :category => 'server', :position => 3
    s2 = create_product :category => 'server', :position => 2
    s3 = create_product :category => 'server', :position => 9
    d1 = create_product :category => 'developer', :position => 6
    d2 = create_product :category => 'developer', :position => 8
    d3 = create_product :category => 'developer', :position => 1
    Product.all.should == [c3, c1, c2, d3, d1, d2, s2, s1, s3]
  end
end
