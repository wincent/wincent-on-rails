require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Product, 'validating the name' do
  it 'should require it to be present' do
    new_product(:name => nil).should fail_validation_for(:name)
  end

  it 'should require it to be unique' do
    name = FR::random_string
    create_product(:name => name).should be_valid
    new_product(:name => name).should fail_validation_for(:name)
  end
end

describe Product, 'validating the permalink' do
  it 'should require it to be present' do
    new_product(:permalink => nil).should fail_validation_for(:permalink)
  end

  it 'should require it to be unique' do
    permalink = FR::random_string
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
    bundle_id = "com.wincent.#{FR::random_string}"
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

describe Product, 'categorized_products method' do
  it 'should return an ordered hash' do
    c1 = create_product :category => 'consumer', :position => 10, :hide_from_front_page => false
    c2 = create_product :category => 'consumer', :position => 15, :hide_from_front_page => false
    c3 = create_product :category => 'consumer', :position => 1, :hide_from_front_page => false
    s1 = create_product :category => 'server', :position => 3, :hide_from_front_page => false
    s2 = create_product :category => 'server', :position => 2, :hide_from_front_page => false
    s3 = create_product :category => 'server', :position => 9, :hide_from_front_page => false
    d1 = create_product :category => 'developer', :position => 6, :hide_from_front_page => false
    d2 = create_product :category => 'developer', :position => 8, :hide_from_front_page => false
    d3 = create_product :category => 'developer', :position => 1, :hide_from_front_page => false
    m1 = create_product :position => 3, :hide_from_front_page => false  # nil/no category
    m2 = create_product :position => 1, :hide_from_front_page => false  # nil/no category
    m3 = create_product :position => 2, :hide_from_front_page => false  # nil/no category
    products = Product.categorized_products
    products.keys.should == [nil, 'consumer', 'developer', 'server']
    products[nil].should == [m2, m3, m1]
    products['consumer'].should == [c3, c1, c2]
    products['developer'].should == [d3, d1, d2]
    products['server'].should == [s2, s1, s3]
  end

  it 'should include only products that are not hidden from front page' do
    p1 = create_product :category => 'consumer', :hide_from_front_page => false
    p2 = create_product :category => 'server'
    products = Product.categorized_products
    products.keys.should == ['consumer']
    products['consumer'].should == [p1]
  end
end
