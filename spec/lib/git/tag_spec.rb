require 'spec_helper'

describe Git::Tag do
  before do
    path = scratch_repo do
      `git tag 0.1 -m "1.0 release"`  # annotated tag
      `echo "bar" > file`
      `git commit -m "tweak" -- file`

      # we'll be testing the chronological order of tags, so make sure they
      # don't happen within the same second
      `GIT_COMMITTER_DATE='#{Time.now.year + 1}-01-01T12:00:00' \
       git tag 0.2 -m "2.0 release"`  # annotated tag

      `echo "baz" > file`
      `git commit -m "WIP" -- file`
      `git tag crazy-idea-WIP`        # lightweight tag
    end
    @repo = Git::Repo.new(path)
  end

  describe '::all' do
    let(:tags) { Git::Tag.all @repo }

    it 'returns an Array of Tag objects' do
      tags.should be_kind_of(Array)
      tags.should_not be_empty
      tags.all? { |tag| tag.kind_of?(Git::Tag) }.should be_true
    end

    it 'returns lightweight tags last' do
      tags.last.name.should == 'refs/tags/crazy-idea-WIP'
      tags.last.lightweight.should be_true
    end

    it 'returns annotated tags in reverse chronological order' do
      tags.pop # remove the lightweight tag
      tags.map(&:name).should == %w(refs/tags/0.2 refs/tags/0.1)
      tags.all? { |t| t.lightweight == false }.should be_true
    end
  end

  describe 'attributes' do
    let(:tag) { @repo.tags.first }

    describe '#repo' do
      it 'returns a reference to the containing repository' do
        tag.repo.should == @repo
      end
    end

    describe '#name' do
      it 'returns the full ref name of the tag' do
        tag.name.should =~ %r{\Arefs/tags/[A-Za-z0-9\-.]+\z}
      end
    end

    describe '#sha1' do
      it 'returns the 40-character SHA-1 hash of the tag' do
        tag.sha1.should =~ /[a-f0-9]{40}/
      end
    end
  end
end
