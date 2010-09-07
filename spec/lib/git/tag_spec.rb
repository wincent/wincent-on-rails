require 'spec_helper'

describe Git::Tag do
  before do
    path = scratch_repo do
      `git tag 0.1 -m "1.0 release"`  # annotated tag
      `echo "bar" > file`
      `git commit -m "tweak" -- file`
      `git tag 0.2 -m "2.0 release"`  # annotated tag
      `echo "baz" > file`
      `git commit -m "WIP" -- file`
      `git tag crazy-idea-WIP`        # lightweight tag
    end
    @repo = Git::Repo.new(path)
  end

  describe '::all' do
    it 'returns an Array of Tag objects' do
      tags = Git::Tag.all @repo
      tags.should be_kind_of(Array)
      tags.should_not be_empty
      tags.all? { |tag| tag.kind_of?(Git::Tag) }.should be_true
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
