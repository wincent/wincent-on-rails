require File.dirname(__FILE__) + '/../spec_helper'

describe Link do
end

describe Link, 'URI validation' do
  it 'should require a URI' do
    link = new_link :uri => nil
    link.should fail_validation_for(:uri)
  end

  it 'should require URIs to be unique' do
    uri = FR::random_string
    link = create_link :uri => uri
    link.should_not fail_validation_for(:uri)
    link = new_link :uri => uri
    link.should fail_validation_for(:uri)
  end
end

describe Link, 'permalink validation' do
  it 'should be valid without a permalink' do
    link = new_link :permalink => nil
    link.should_not fail_validation_for(:permalink)
  end

  it 'should require permalinks to be unique' do
    permalink = FR::random_string
    link = create_link :permalink => permalink
    link.should_not fail_validation_for(:permalink)
    link = new_link :permalink => permalink
    link.should fail_validation_for(:permalink)
  end

  it 'should accept nil permalinks without triggering uniqueness validation failures' do
    link = create_link :permalink => nil
    link.should_not fail_validation_for(:permalink)
    link = new_link :permalink => nil
    link.should_not fail_validation_for(:permalink)
  end
end

describe Link, 'accessible attributes' do
  it 'should allow mass-assignment to the uri' do
    new_link.should allow_mass_assignment_of(:uri => FR::random_string)
  end

  it 'should allow mass-assignment to the permalink' do
    new_link.should allow_mass_assignment_of(:permalink => FR::random_string)
  end
end

describe Link, 'protected attributes' do
  it 'should deny mass-assignment ot the click count' do
    new_link.should_not allow_mass_assignment_of(:click_count => 200)
  end
end

describe Link, 'parametrization' do
  it 'should use permalink as param if available' do
    link = create_link
    link.to_param.should == link.permalink
  end

  it 'should use id as param if permalink not available' do
    link = create_link :permalink => nil
    link.to_param.should == link.id
  end
end

describe Link, 'click count' do
  it 'should default to 0' do
    create_link.click_count.should == 0
  end
end
