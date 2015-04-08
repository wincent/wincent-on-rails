require 'spec_helper'
require 'pathname'

describe Repo do
  describe 'attributes' do
    describe '#name' do
      it 'defaults to nil' do
        expect(Repo.new.name).to be_nil
      end

      it 'is accessible' do
        expect(Repo.make).to allow_mass_assignment_of(:name => 'hello')
      end
    end

    describe '#permalink' do
      it 'defaults to nil' do
        expect(Repo.new.permalink).to be_nil
      end

      it 'is accessible' do
        expect(Repo.make).to allow_mass_assignment_of(:permalink => 'world')
      end
    end

    describe '#path' do
      it 'defaults to nil' do
        expect(Repo.new.path).to be_nil
      end

      it 'is accessible' do
        expect(Repo.make).to allow_mass_assignment_of(:path => '/new/path')
      end
    end

    describe '#description' do
      it 'defaults to nil' do
        expect(Repo.new.description).to be_nil
      end

      it 'is accessible' do
        expect(Repo.make).to allow_mass_assignment_of(:description => 'a repo')
      end
    end

    describe '#product_id' do
      it 'defaults to nil' do
        expect(Repo.new.product_id).to be_nil
      end

      it 'is accessible' do
        expect(Repo.make).to allow_mass_assignment_of(:product_id => Product.make!.id)
      end
    end

    describe '#public' do
      it 'defaults to false' do
        expect(Repo.new.public).to eq(false)
      end

      it 'is accessible' do
        expect(Repo.make(:public => false)).to allow_mass_assignment_of(:public => true)
      end
    end

    describe '#created_at' do
      it 'defaults to nil' do
        expect(Repo.new.created_at).to be_nil
      end
    end

    describe '#updated_at' do
      it 'defaults to nil' do
        expect(Repo.new.updated_at).to be_nil
      end
    end

    describe '#clone_url' do
      it 'defaults to nil' do
        expect(Repo.new.clone_url).to be_nil
      end

      it 'is accessible' do
        expect(Repo.make).to allow_mass_assignment_of(:clone_url => 'git://git.example.com/new.git')
      end
    end

    describe '#rw_clone_url' do
      it 'defaults to nil' do
        expect(Repo.new.rw_clone_url).to be_nil
      end

      it 'is accessible' do
        expect(Repo.make).to allow_mass_assignment_of(:rw_clone_url => 'git://git.example.com/new.git')
      end
    end
  end

  describe 'validation' do
    describe 'clone_url attribute' do
      it 'must be unique' do
        Repo.make! :clone_url => 'git.example.com:/foo.git'
        expect(Repo.make(:clone_url => 'git.example.com:/foo.git')).
          to fail_validation_for(:clone_url)
      end

      it 'does not fail uniqueness validation for nil values' do
        Repo.make! :clone_url => nil
        expect(Repo.make!(:clone_url => nil)).
          not_to fail_validation_for(:clone_url)
      end

      it 'does not fail uniqueness validation for blank values' do
        Repo.make! :clone_url => ''
        expect(Repo.make!(:clone_url => '')).
          not_to fail_validation_for(:clone_url)
      end

      it 'has a database-level constraint to guard against race conditions' do
        Repo.make! :clone_url => 'git.example.com:/foo.git'
        expect do
          repo = Repo.make!
          repo.clone_url = 'git.example.com:/foo.git'
          repo.save :validate => false
        end.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end

    describe 'name attribute' do
      it 'must be present' do
        expect(Repo.make(:name => nil)).to fail_validation_for(:name)
      end

      it 'must be unique' do
        Repo.make! :name => 'foo'
        expect(Repo.make(:name => 'foo')).to fail_validation_for(:name)
      end

      it 'has a database-level constraint to guard against race conditions' do
        Repo.make! :name => 'foo'
        expect do
          repo = Repo.make!
          repo.name = 'foo'
          repo.save :validate => false
        end.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end

    describe 'permalink attribute' do
      it 'must be present' do
        expect(Repo.make(:permalink => nil)).to fail_validation_for(:permalink)
      end

      it 'must be unique' do
        Repo.make! :permalink => 'foo'
        expect(Repo.make(:permalink => 'foo')).to fail_validation_for(:permalink)
      end

      it 'has a database-level constraint to guard against race conditions' do
        Repo.make! :permalink => 'foo'
        expect do
          repo = Repo.make!
          repo.permalink = 'foo'
          repo.save :validate => false
        end.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end

    describe 'path attribute' do
      it 'must be present' do
        expect(Repo.make(:path => nil)).to fail_validation_for(:path)
      end

      it 'must be unique' do
        repo = Repo.make!
        expect(Repo.make(:path => repo.path)).to fail_validation_for(:path)
      end

      it 'must exist on disk' do
        expect(Repo.make(:path => '/unlikely/to/exist')).
          to fail_validation_for(:path)
      end

      it 'must be readable' do
        path = Pathname.new Dir.mkdtemp
        path.chmod 0000
        expect(Repo.make(path: path.to_s)).
          to fail_validation_for(:path)
      end

      it 'must be a Git repository' do
        expect(Repo.make(:path => Dir.mkdtemp)).
          to fail_validation_for(:path)
      end

      it 'has a database-level constraint to guard against race conditions' do
        repo1 = Repo.make!
        expect do
          repo2 = Repo.make!
          repo2.path = repo1.path
          repo2.save validate: false
        end.to raise_error(ActiveRecord::RecordNotUnique)
      end

      specify 'RAILS_ROOT is valid' do
        expect(Repo.make(path: Rails.root.to_s)).not_to fail_validation_for(:path)
      end

      specify '"non-pathy string!" is not valid' do
        expect(Repo.make(path: 'non-pathy string!')).to fail_validation_for(:path)
      end
    end

    describe 'product_id attribute' do
      it 'must be unique' do
        product = Product.make!
        Repo.make! :product_id => product.id
        expect(Repo.make(:product_id => product.id)).
          to fail_validation_for(:product_id)
      end

      it 'does not fail uniqueness validation for nil values' do
        Repo.make! :product_id => nil
        expect(Repo.make(:product_id => nil)).
          not_to fail_validation_for(:product_id)
      end

      it 'has a database-level constraint to guard against race conditions' do
        product = Product.make!
        Repo.make! product_id: product.id
        expect do
          repo = Repo.make!
          repo.product_id = product.id
          repo.save validate: false
        end.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end

    describe 'rw_clone_url attribute' do
      it 'must be unique' do
        Repo.make! :rw_clone_url => 'git.example.com:/foo.git'
        expect(Repo.make(:rw_clone_url => 'git.example.com:/foo.git')).
          to fail_validation_for(:rw_clone_url)
      end

      it 'does not fail uniqueness validation for nil values' do
        Repo.make! :rw_clone_url => nil
        expect(Repo.make!(:rw_clone_url => nil)).
          not_to fail_validation_for(:rw_clone_url)
      end

      it 'does not fail uniqueness validation for blank values' do
        Repo.make! :rw_clone_url => ''
        expect(Repo.make!(:rw_clone_url => '')).
          not_to fail_validation_for(:rw_clone_url)
      end

      it 'has a database-level constraint to guard against race conditions' do
        product = Product.make!
        Repo.make! :rw_clone_url => 'git.example.com:/foo.git'
        expect do
          repo = Repo.make!
          repo.rw_clone_url = 'git.example.com:/foo.git'
          repo.save :validate => false
        end.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end

  describe 'associations' do
    describe 'product' do
      it 'belongs to a product' do
        product = Product.make!
        repo = Repo.make!(:product => product)
        expect(repo.product).to eq(product)
      end

      it 'does not complain if the product is not present' do
        expect(Repo.make!(:product => nil)).to be_valid
      end
    end
  end

  describe '#published' do
    it 'returns public repos' do
      repo  = Repo.make! :public => true
      other = Repo.make! :public => false
      expect(Repo.published.to_a).to eq([repo])
    end
  end

  describe '#to_param' do
    context 'new record' do
      it 'returns the permalink' do
        repo = Repo.make :permalink => 'foo'
        expect(repo.to_param).to eq('foo')
      end
    end

    context 'dirty record' do
      it 'returns the old permalink' do
        repo = Repo.make! :permalink => 'foo'
        repo.permalink = 'bar'
        expect(repo.to_param).to eq('foo')
      end
    end
  end
end
