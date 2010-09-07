require 'spec_helper'
require 'pathname'

describe Repo do
  describe 'attributes' do
    describe '#name' do
      it 'defaults to nil' do
        Repo.new.name.should be_nil
      end

      it 'is accessible' do
        Repo.make.should allow_mass_assignment_of(:name => 'hello')
      end
    end

    describe '#permalink' do
      it 'defaults to nil' do
        Repo.new.permalink.should be_nil
      end

      it 'is accessible' do
        Repo.make.should allow_mass_assignment_of(:permalink => 'world')
      end
    end

    describe '#path' do
      it 'defaults to nil' do
        Repo.new.path.should be_nil
      end

      it 'is accessible' do
        Repo.make.should allow_mass_assignment_of(:path => '/new/path')
      end
    end

    describe '#description' do
      it 'defaults to nil' do
        Repo.new.description.should be_nil
      end

      it 'is accessible' do
        Repo.make.should allow_mass_assignment_of(:description => 'a repo')
      end
    end

    describe '#product_id' do
      it 'defaults to nil' do
        Repo.new.product_id.should be_nil
      end

      it 'is accessible' do
        Repo.make.should allow_mass_assignment_of(:product_id => Product.make!.id)
      end
    end

    describe '#public' do
      it 'defaults to false' do
        Repo.new.public.should be_false
      end

      it 'is accessible' do
        Repo.make(:public => false).should allow_mass_assignment_of(:public => true)
      end
    end

    describe '#created_at' do
      it 'defaults to nil' do
        Repo.new.created_at.should be_nil
      end
    end

    describe '#updated_at' do
      it 'defaults to nil' do
        Repo.new.updated_at.should be_nil
      end
    end

    describe '#clone_url' do
      it 'defaults to nil' do
        Repo.new.clone_url.should be_nil
      end

      it 'is accessible' do
        Repo.make.should allow_mass_assignment_of(:clone_url => 'git://git.example.com/new.git')
      end
    end

    describe '#rw_clone_url' do
      it 'defaults to nil' do
        Repo.new.rw_clone_url.should be_nil
      end

      it 'is accessible' do
        Repo.make.should allow_mass_assignment_of(:rw_clone_url => 'git://git.example.com/new.git')
      end
    end
  end

  describe 'validation' do
    describe 'clone_url attribute' do
      it 'must be unique' do
        Repo.make! :clone_url => 'git.example.com:/foo.git'
        Repo.make(:clone_url => 'git.example.com:/foo.git').
          should fail_validation_for(:clone_url)
      end

      it 'does not fail uniqueness validation for nil values' do
        Repo.make! :clone_url => nil
        Repo.make(:clone_url => nil).
          should_not fail_validation_for(:clone_url)
      end

      it 'does not fail uniqueness validation for blank values' do
        Repo.make! :clone_url => nil
        Repo.make(:clone_url => nil).
          should_not fail_validation_for(:clone_url)
      end

      it 'has a database-level constraint to guard against race conditions' do
        Repo.make! :clone_url => 'git.example.com:/foo.git'
        expect do
          repo = Repo.make!
          repo.clone_url = 'git.example.com:/foo.git'
          repo.save :validate => false
        end.should raise_error(ActiveRecord::RecordNotUnique)
      end
    end

    describe 'name attribute' do
      it 'must be present' do
        Repo.make(:name => nil).should fail_validation_for(:name)
      end

      it 'must be unique' do
        Repo.make! :name => 'foo'
        Repo.make(:name => 'foo').should fail_validation_for(:name)
      end

      it 'has a database-level constraint to guard against race conditions' do
        Repo.make! :name => 'foo'
        expect do
          repo = Repo.make!
          repo.name = 'foo'
          repo.save :validate => false
        end.should raise_error(ActiveRecord::RecordNotUnique)
      end
    end

    describe 'permalink attribute' do
      it 'must be present' do
        Repo.make(:permalink => nil).should fail_validation_for(:permalink)
      end

      it 'must be unique' do
        Repo.make! :permalink => 'foo'
        Repo.make(:permalink => 'foo').should fail_validation_for(:permalink)
      end

      it 'has a database-level constraint to guard against race conditions' do
        Repo.make! :permalink => 'foo'
        expect do
          repo = Repo.make!
          repo.permalink = 'foo'
          repo.save :validate => false
        end.should raise_error(ActiveRecord::RecordNotUnique)
      end
    end

    describe 'path attribute' do
      it 'must be present' do
        Repo.make(:path => nil).should fail_validation_for(:path)
      end

      it 'must be unique' do
        repo = Repo.make!
        Repo.make(:path => repo.path).should fail_validation_for(:path)
      end

      it 'must exist on disk' do
        Repo.make(:path => '/unlikely/to/exist').
          should fail_validation_for(:path)
      end

      it 'must be readable' do
        path = Pathname.new Dir.mkdtemp
        path.chmod 0000
        Repo.make(:path => path).
          should fail_validation_for(:path)
      end

      it 'must be a Git repository' do
        Repo.make(:path => Dir.mkdtemp).
          should fail_validation_for(:path)
      end

      it 'has a database-level constraint to guard against race conditions' do
        repo1 = Repo.make!
        expect do
          repo2 = Repo.make!
          repo2.path = repo1.path
          repo2.save :validate => false
        end.should raise_error(ActiveRecord::RecordNotUnique)
      end

      specify 'RAILS_ROOT is valid' do
        Repo.make(:path => Rails.root).should_not fail_validation_for(:path)
      end

      specify '"non-pathy string!" is not valid' do
        Repo.make(:path => 'non-pathy string!').should fail_validation_for(:path)
      end
    end

    describe 'product_id attribute' do
      it 'must be unique' do
        product = Product.make!
        Repo.make! :product_id => product.id
        Repo.make(:product_id => product.id).
          should fail_validation_for(:product_id)
      end

      it 'does not fail uniqueness validation for nil values' do
        Repo.make! :product_id => nil
        Repo.make(:product_id => nil).
          should_not fail_validation_for(:product_id)
      end

      it 'has a database-level constraint to guard against race conditions' do
        product = Product.make!
        Repo.make! :product_id => product.id
        expect do
          repo = Repo.make!
          repo.product_id = product.id
          repo.save :validate => false
        end.should raise_error(ActiveRecord::RecordNotUnique)
      end
    end

    describe 'rw_clone_url attribute' do
      it 'must be unique' do
        Repo.make! :rw_clone_url => 'git.example.com:/foo.git'
        Repo.make(:rw_clone_url => 'git.example.com:/foo.git').
          should fail_validation_for(:rw_clone_url)
      end

      it 'does not fail uniqueness validation for nil values' do
        Repo.make! :rw_clone_url => nil
        Repo.make(:rw_clone_url => nil).
          should_not fail_validation_for(:rw_clone_url)
      end

      it 'does not fail uniqueness validation for blank values' do
        Repo.make! :rw_clone_url => nil
        Repo.make(:rw_clone_url => nil).
          should_not fail_validation_for(:rw_clone_url)
      end

      it 'has a database-level constraint to guard against race conditions' do
        product = Product.make!
        Repo.make! :rw_clone_url => 'git.example.com:/foo.git'
        expect do
          repo = Repo.make!
          repo.rw_clone_url = 'git.example.com:/foo.git'
          repo.save :validate => false
        end.should raise_error(ActiveRecord::RecordNotUnique)
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
