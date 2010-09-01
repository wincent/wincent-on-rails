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

describe Link  do
  describe '#uri' do
    it 'defaults to nil' do
      Link.new.uri.should be_nil
    end
  end

  describe '#permalink' do
    it 'defaults to nil' do
      Link.new.permalink.should be_nil
    end
  end

  describe '#click_count' do
    it 'defaults to zero' do
      Link.new.click_count.should be_zero
    end
  end

  describe '#created_at' do
    it 'defaults to nil' do
      Link.new.created_at.should be_nil
    end
  end

  describe '#updated_at' do
    it 'defaults to nil' do
      Link.new.updated_at.should be_nil
    end
  end

  describe '#to_param' do
    it 'uses permalink as param if available' do
      link = Link.make!
      link.to_param.should == link.permalink
    end

    it 'uses id as param if permalink not available' do
      link = Link.make! :permalink => nil
      link.to_param.should == link.id
    end

    context 'new record' do
      it 'returns nil' do
        Link.new.to_param.should be_nil
      end
    end

    context 'dirty record' do
      it 'returns the old (on database) permalink' do
        link = Link.make! :permalink => 'foo'
        link.permalink = 'bar'
        link.to_param.should == 'foo'
      end
    end
  end
end

describe Link, 'click count' do
  it 'should default to 0' do
    Link.make!.click_count.should == 0
  end
end
