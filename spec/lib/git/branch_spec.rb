require 'spec_helper'

describe Git::Branch do
  let :repo do
    path = scratch_repo do
      `git branch baz`
      `git branch bing`
    end
    Git::Repo.new(path)
  end

  describe '::all' do
    it 'returns an Array of Branch objects' do
      branches = Git::Branch.all repo
      branches.should be_kind_of(Array)
      branches.should_not be_empty
      branches.all? { |branch| branch.kind_of?(Git::Branch) }.should == true
    end
  end

  describe '::branch' do
    it 'returns a single Branch object' do
      branch = Git::Branch.branch 'master', repo
      branch.should be_kind_of(Git::Branch)
      branch.name.should == 'refs/heads/master'
    end

    context 'non-existent branch' do
      it 'complains' do
        expect do
          Git::Branch.branch 'foobar', repo
        end.to raise_error(Git::Ref::NonExistentRefError)
      end
    end
  end

  describe 'attributes' do
    let(:branch) { repo.branches.first }

    describe '#repo' do
      it 'returns a reference to the containing repository' do
        branch.repo.should == repo
      end
    end

    describe '#name' do
      it 'returns the full ref name of the branch' do
        branch.name.should =~ %r{\Arefs/heads/\w+\z}
      end
    end

    describe '#sha1' do
      it 'returns the 40-character SHA-1 hash of the branch' do
        branch.sha1.should =~ /[a-f0-9]{40}/
      end
    end
  end
end
