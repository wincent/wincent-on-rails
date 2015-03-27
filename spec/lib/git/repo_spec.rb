require 'spec_helper'
require 'mkdtemp'
require 'pathname'

describe Git::Repo do
  describe '#initialize' do
    it 'requires a path' do
      expect do
        Git::Repo.new
      end.to raise_error(ArgumentError)
    end

    it 'complains if path is nil' do
      expect do
        Git::Repo.new nil
      end.to raise_error(ArgumentError)
    end

    it 'complains if path does not exist' do
      expect do
        Git::Repo.new 'some/non/existent/path'
      end.to raise_error(Errno::ENOENT)
    end

    it 'complains if path is not a directory' do
      dir = Dir.mkdtemp do
        FileUtils.touch 'file'
      end
      file = Pathname.new(dir) + 'file'
      expect do
        Git::Repo.new file
      end.to raise_error(Errno::ENOTDIR)
    end

    it 'complains if path is not a Git repository' do
      expect do
        Git::Repo.new Dir.mkdtemp
      end.to raise_error(Git::NoRepositoryError)
    end

    context 'with a valid Git repository' do
      before do
        @repo_path = scratch_repo
      end

      it 'succeeds' do
        expect do
          Git::Repo.new @repo_path
        end.to_not raise_error
      end
    end
  end

  describe '#git' do
    it 'allows other objects to run "git" commands in the repo' do
      repo = Git::Repo.new scratch_repo
      repo.git('log').stdout.should =~ /Initial import/i
    end
  end

  describe '#path' do
    it 'returns a Pathname instance' do
      Git::Repo.new(scratch_repo).path.should be_kind_of(Pathname)
    end

    context 'bare repo' do
      it 'returns the path passed in to #new' do
        path = bare_scratch_repo
        Git::Repo.new(path).path.to_s.should == path
      end
    end

    context 'non-bare repo' do
      it 'returns the path passed in to #new' do
        path = scratch_repo
        Git::Repo.new(path).path.to_s.should == path
      end
    end
  end

  describe '#git_dir' do
    it 'returns a Pathname instance' do
      Git::Repo.new(scratch_repo).git_dir.should be_kind_of(Pathname)
    end

    context 'bare repo' do
      it 'returns the path passed in to #new' do
        path = bare_scratch_repo
        Git::Repo.new(path).git_dir.to_s.should == path
      end
    end

    context 'non-bare repo' do
      it 'returns the path to the .git directory inside the repo' do
        path = scratch_repo
        Git::Repo.new(path).git_dir.to_s.should == "#{path}/.git"
      end
    end
  end

  describe '#head' do
    before do
      @repo = Git::Repo.new scratch_repo
    end

    it 'returns a Ref object' do
      @repo.head.should be_kind_of(Git::Ref)
    end

    specify 'the returned object matches the current HEAD' do
      @repo.head.name.should == 'HEAD'
    end
  end

  describe '#branches' do
    before do
      path = scratch_repo do
        `git branch baz`
        `git branch bing`
      end
      @repo = Git::Repo.new(path)
      @branches = @repo.branches
    end

    it 'returns an array of Branch objects' do
      @branches.should be_kind_of(Array)
      @branches.should_not be_empty
      @branches.all? { |branch| branch.kind_of?(Git::Branch) }.should == true
    end
  end

  describe '#tags' do
    before do
      path = scratch_repo do
        `git tag 0.1 -m "1.0 release"`
        `echo "bar" > file`
        `git commit -m "tweak" -- file`
        `git tag 0.2 -m "2.0 release"`
      end
      @repo = Git::Repo.new(path)
      @tags = @repo.tags
    end

    it 'returns an array of Tag objects' do
      @tags.should be_kind_of(Array)
      @tags.should_not be_empty
      @tags.all? { |tag| tag.kind_of?(Git::Tag) }.should == true
    end
  end
end
