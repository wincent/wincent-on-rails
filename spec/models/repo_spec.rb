require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Repo do
  describe 'attributes' do
    describe 'name' do
      it 'is accessible' do
        Repo.make.should allow_mass_assignment_of(:name => 'hello')
      end
    end

    describe 'permalink' do
      it 'is accessible' do
        Repo.make.should allow_mass_assignment_of(:permalink => 'world')
      end
    end

    describe 'path' do
      it 'is accessible' do
        Repo.make.should allow_mass_assignment_of(:path => '/new/path')
      end
    end

    describe 'description' do
      it 'is accessible' do
        Repo.make.should allow_mass_assignment_of(:description => 'a repo')
      end
    end

    describe 'product' do
      it 'is accessible' do
        Repo.make.should allow_mass_assignment_of(:product_id => Product.make!.id)
      end
    end

    describe 'public' do
      it 'defaults to false' do
        Repo.new.public.should be_false
      end

      it 'is accessible' do
        Repo.make(:public => false).should allow_mass_assignment_of(:public => true)
      end
    end

    describe 'clone_url' do
      it 'is accessible' do
        Repo.make.should allow_mass_assignment_of(:clone_url => 'git://git.example.com/new.git')
      end
    end

    describe 'rw_clone_url' do
      it 'is accessible' do
        Repo.make.should allow_mass_assignment_of(:rw_clone_url => 'git://git.example.com/new.git')
      end
    end
  end

  describe 'validation' do
    describe 'name attribute' do
      it 'must be present' do
        Repo.make(:name => nil).should fail_validation_for(:name)
      end
    end

    describe 'permalink attribute' do
      it 'must be present' do
        Repo.make(:permalink => nil).should fail_validation_for(:permalink)
      end
    end

    describe 'path attribute' do
      it 'must be present' do
        Repo.make(:path => nil).should fail_validation_for(:path)
      end

      specify '"/foo/bar/baz" is valid' do
        Repo.make(:path => '/foo/bar/baz').should_not fail_validation_for(:path)
      end

      specify '"non-pathy string!" is not valid' do
        Repo.make(:path => 'non-pathy string!').should fail_validation_for(:path)
      end
    end
  end

  describe 'associations' do
    describe 'product' do
      it 'belongs to a product' do
        product = Product.make!
        repo = Repo.make!(:product => product)
        repo.product.should == product
      end

      it 'does not complain if the product is not present' do
        Repo.make!(:product => nil).should be_valid
      end
    end
  end

  describe '#to_param' do
    context 'new record' do
      it 'returns the permalink' do
        repo = Repo.make :permalink => 'foo'
        repo.to_param.should == 'foo'
      end
    end

    context 'dirty record' do
      it 'returns the old permalink' do
        repo = Repo.make! :permalink => 'foo'
        repo.permalink = 'bar'
        repo.to_param.should == 'foo'
      end
    end
  end
end
