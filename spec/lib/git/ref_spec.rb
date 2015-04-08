require 'spec_helper'

describe Git::Ref do
  before do
    @repo = Git::Repo.new(scratch_repo)
    @ref = Git::Ref.head @repo
  end

  describe '::head' do
    it 'returns a Ref instance' do
      expect(@ref).to be_kind_of(Git::Ref)
    end

    specify 'returned objects matches HEAD' do
      expect(@ref.name).to eq('HEAD')
    end
  end

  describe '#commits' do
    before do
      Dir.chdir @repo.path do
        i = 1
        25.times do
          `echo stuff >> file`
          `git commit -m "Addition \##{i}"`
          i += 1
        end
      end

    end

    it 'returns an array of Commit objects' do
      expect(@ref.commits).to be_kind_of(Array)
      expect(@ref.commits).not_to be_empty
      expect(@ref.commits.all? { |commit| commit.kind_of?(Git::Commit) }).to eq(true)
    end

    it 'returns at most 20 commits' do
      expect(@ref.commits.size).to be <= 20
    end
  end
end
