require 'spec_helper'

describe Git::Ref do
  before do
    @repo = Git::Repo.new(scratch_repo)
    @ref = Git::Ref.head @repo
  end

  describe '::head' do
    it 'returns a Ref instance' do
      @ref.should be_kind_of(Git::Ref)
    end

    specify 'returned objects matches HEAD' do
      @ref.name.should == 'HEAD'
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
      @ref.commits.should be_kind_of(Array)
      @ref.commits.should_not be_empty
      @ref.commits.all? { |commit| commit.kind_of?(Git::Commit) }.should == true
    end

    it 'returns at most 20 commits' do
      @ref.commits.size.should <= 20
    end
  end
end
