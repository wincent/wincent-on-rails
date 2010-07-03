require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Product, 'validating the name' do
  it 'should require it to be present' do
    Product.make(:name => nil).should fail_validation_for(:name)
  end

  it 'should require it to be unique' do
    name = Sham.random
    Product.make!(:name => name).should be_valid
    Product.make(:name => name).should fail_validation_for(:name)
  end
end

describe Product, 'validating the permalink' do
  it 'should require it to be present' do
    Product.make(:permalink => nil).should fail_validation_for(:permalink)
  end

  it 'should require it to be unique' do
    permalink = Sham.random
    Product.make!(:permalink => permalink).should be_valid
    Product.make(:permalink => permalink).should fail_validation_for(:permalink)
  end
end

describe Product, 'validating the bundle identifier' do
  it 'should not require it to be present' do
    product = Product.make!(:bundle_identifier => nil)
    product.should_not fail_validation_for(:bundle_identifier)
  end

  it 'should require it to be unique ' do
    bundle_id = "com.wincent.#{Sham.random}"
    Product.make!(:bundle_identifier => bundle_id).should be_valid
    product = Product.make(:bundle_identifier => bundle_id)
    product.should fail_validation_for(:bundle_identifier)
  end

  it 'should permit multiple products with no bundle identifier' do
    2.times { Product.make!(:bundle_identifier => nil).should be_valid }
    2.times { Product.make!(:bundle_identifier => '').should be_valid }
  end
end

describe Product, 'default scope' do
  it 'should return products in category order by default' do
    c1 = Product.make! :category => 'consumer', :position => 10
    s1 = Product.make! :category => 'server', :position => 3
    d1 = Product.make! :category => 'developer', :position => 6
    Product.all.should == [c1, d1, s1]
  end

  it 'should return products in position order within each category' do
    c1 = Product.make! :category => 'consumer', :position => 10
    c2 = Product.make! :category => 'consumer', :position => 15
    c3 = Product.make! :category => 'consumer', :position => 1
    s1 = Product.make! :category => 'server', :position => 3
    s2 = Product.make! :category => 'server', :position => 2
    s3 = Product.make! :category => 'server', :position => 9
    d1 = Product.make! :category => 'developer', :position => 6
    d2 = Product.make! :category => 'developer', :position => 8
    d3 = Product.make! :category => 'developer', :position => 1
    Product.all.should == [c3, c1, c2, d3, d1, d2, s2, s1, s3]
  end
end

describe Product, 'categorized method' do
  it 'returns an ordered hash' do
    c1 = Product.make! :category => 'consumer', :position => 10, :hide_from_front_page => false
    c2 = Product.make! :category => 'consumer', :position => 15, :hide_from_front_page => false
    c3 = Product.make! :category => 'consumer', :position => 1, :hide_from_front_page => false
    s1 = Product.make! :category => 'server', :position => 3, :hide_from_front_page => false
    s2 = Product.make! :category => 'server', :position => 2, :hide_from_front_page => false
    s3 = Product.make! :category => 'server', :position => 9, :hide_from_front_page => false
    d1 = Product.make! :category => 'developer', :position => 6, :hide_from_front_page => false
    d2 = Product.make! :category => 'developer', :position => 8, :hide_from_front_page => false
    d3 = Product.make! :category => 'developer', :position => 1, :hide_from_front_page => false
    m1 = Product.make! :position => 3, :hide_from_front_page => false  # nil/no category
    m2 = Product.make! :position => 1, :hide_from_front_page => false  # nil/no category
    m3 = Product.make! :position => 2, :hide_from_front_page => false  # nil/no category
    products = Product.categorized
    products.keys.should == ['', 'consumer', 'developer', 'server']
    products[''].should == [m2, m3, m1]
    products['consumer'].should == [c3, c1, c2]
    products['developer'].should == [d3, d1, d2]
    products['server'].should == [s2, s1, s3]
  end

  it 'includes all products, even those hidden from front page' do
    p1 = Product.make! :category => 'consumer', :hide_from_front_page => false
    p2 = Product.make! :category => 'server'
    products = Product.categorized
    products.keys.should == ['consumer', 'server']
    products['consumer'].should == [p1]
    products['server'].should == [p2]
  end
end

describe Product, 'front_page scope' do
  pending
end
