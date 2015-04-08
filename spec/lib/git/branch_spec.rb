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
      expect(branches).to be_kind_of(Array)
      expect(branches).not_to be_empty
      expect(branches.all? { |branch| branch.kind_of?(Git::Branch) }).to eq(true)
    end
  end

  describe '::branch' do
    it 'returns a single Branch object' do
      branch = Git::Branch.branch 'master', repo
      expect(branch).to be_kind_of(Git::Branch)
      expect(branch.name).to eq('refs/heads/master')
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
        expect(branch.repo).to eq(repo)
      end
    end

    describe '#name' do
      it 'returns the full ref name of the branch' do
        expect(branch.name).to match(%r{\Arefs/heads/\w+\z})
      end
    end

    describe '#sha1' do
      it 'returns the 40-character SHA-1 hash of the branch' do
        expect(branch.sha1).to match(/[a-f0-9]{40}/)
      end
    end
  end
end
