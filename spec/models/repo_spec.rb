require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Repo do
  describe 'attributes' do
    describe 'public' do
      it 'defaults to false' do
        Repo.new.public.should be_false
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
end
