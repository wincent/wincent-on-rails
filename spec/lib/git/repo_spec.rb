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
      expect(repo.git('log').stdout).to match(/Initial import/i)
    end
  end

  describe '#path' do
    it 'returns a Pathname instance' do
      expect(Git::Repo.new(scratch_repo).path).to be_kind_of(Pathname)
    end

    context 'bare repo' do
      it 'returns the path passed in to #new' do
        path = bare_scratch_repo
        expect(Git::Repo.new(path).path.to_s).to eq(path)
      end
    end

    context 'non-bare repo' do
      it 'returns the path passed in to #new' do
        path = scratch_repo
        expect(Git::Repo.new(path).path.to_s).to eq(path)
      end
    end
  end

  describe '#git_dir' do
    it 'returns a Pathname instance' do
      expect(Git::Repo.new(scratch_repo).git_dir).to be_kind_of(Pathname)
    end

    context 'bare repo' do
      it 'returns the path passed in to #new' do
        path = bare_scratch_repo
        expect(Git::Repo.new(path).git_dir.to_s).to eq(path)
      end
    end

    context 'non-bare repo' do
      it 'returns the path to the .git directory inside the repo' do
        path = scratch_repo
        expect(Git::Repo.new(path).git_dir.to_s).to eq("#{path}/.git")
      end
    end
  end

  describe '#head' do
    before do
      @repo = Git::Repo.new scratch_repo
    end

    it 'returns a Ref object' do
      expect(@repo.head).to be_kind_of(Git::Ref)
    end

    specify 'the returned object matches the current HEAD' do
      expect(@repo.head.name).to eq('HEAD')
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
      expect(@branches).to be_kind_of(Array)
      expect(@branches).not_to be_empty
      expect(@branches.all? { |branch| branch.kind_of?(Git::Branch) }).to eq(true)
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
      expect(@tags).to be_kind_of(Array)
      expect(@tags).not_to be_empty
      expect(@tags.all? { |tag| tag.kind_of?(Git::Tag) }).to eq(true)
    end
  end
end
