require File.expand_path('../../spec_helper', File.dirname(__FILE__))
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
end
