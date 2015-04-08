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
      expect(tags).to be_kind_of(Array)
      expect(tags).not_to be_empty
      expect(tags.all? { |tag| tag.kind_of?(Git::Tag) }).to eq(true)
    end

    it 'returns lightweight tags last' do
      expect(tags.last.name).to eq('refs/tags/crazy-idea-WIP')
      expect(tags.last.lightweight).to eq(true)
    end

    it 'returns annotated tags in reverse chronological order' do
      tags.pop # remove the lightweight tag
      expect(tags.map(&:name)).to eq(%w(refs/tags/0.2 refs/tags/0.1))
      expect(tags.all? { |t| t.lightweight == false }).to eq(true)
    end
  end

  describe 'attributes' do
    let(:tag) { @repo.tags.first }

    describe '#repo' do
      it 'returns a reference to the containing repository' do
        expect(tag.repo).to eq(@repo)
      end
    end

    describe '#name' do
      it 'returns the full ref name of the tag' do
        expect(tag.name).to match(%r{\Arefs/tags/[A-Za-z0-9\-.]+\z})
      end
    end

    describe '#sha1' do
      it 'returns the 40-character SHA-1 hash of the tag' do
        expect(tag.sha1).to match(/[a-f0-9]{40}/)
      end
    end
  end
end
