require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Link, 'URI validation' do
  it 'should require a URI' do
    link = Link.make :uri => nil
    link.should fail_validation_for(:uri)
  end

  it 'should require URIs to be unique' do
    uri = Sham.random
    link = Link.make! :uri => uri
    link.should_not fail_validation_for(:uri)
    link = Link.make :uri => uri
    link.should fail_validation_for(:uri)
  end
end

describe Link, 'permalink validation' do
  it 'should be valid without a permalink' do
    link = Link.make :permalink => nil
    link.should_not fail_validation_for(:permalink)
  end

  it 'should require permalinks to be unique' do
    permalink = Sham.random
    link = Link.make! :permalink => permalink
    link.should_not fail_validation_for(:permalink)
    link = Link.make :permalink => permalink
    link.should fail_validation_for(:permalink)
  end

  it 'should accept nil permalinks without triggering uniqueness validation failures' do
    link = Link.make! :permalink => nil
    link.should_not fail_validation_for(:permalink)
    link = Link.make :permalink => nil
    link.should_not fail_validation_for(:permalink)
  end
end

describe Link, 'accessible attributes' do
  it 'should allow mass-assignment to the uri' do
    Link.make.should allow_mass_assignment_of(:uri => Sham.random)
  end

  it 'should allow mass-assignment to the permalink' do
    Link.make.should allow_mass_assignment_of(:permalink => Sham.random)
  end
end

describe Link, 'protected attributes' do
  it 'should deny mass-assignment ot the click count' do
    Link.make.should_not allow_mass_assignment_of(:click_count => 200)
  end
end

describe Link, 'parametrization' do
  it 'should use permalink as param if available' do
    link = Link.make!
    link.to_param.should == link.permalink
  end

  it 'should use id as param if permalink not available' do
    link = Link.make! :permalink => nil
    link.to_param.should == link.id
  end
end

describe Link, 'click count' do
  it 'should default to 0' do
    Link.make!.click_count.should == 0
  end
end
