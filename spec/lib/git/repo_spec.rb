require File.expand_path('../../spec_helper', File.dirname(__FILE__))
require 'mkdtemp'

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
end
