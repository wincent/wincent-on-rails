require 'spec_helper'

describe Tag do
  before do
    stub(TagMapping).mappings { {} }
  end

  describe 'attributes' do
    describe '#name' do
      it 'defaults to nil' do
        expect(Tag.new.name).to be_nil
      end
    end

    describe '#taggings_count' do
      it 'defaults to zero' do
        expect(Tag.new.taggings_count).to be_zero
      end
    end

    describe '#created_at' do
      it 'defaults to nil' do
        expect(Tag.new.created_at).to be_nil
      end
    end

    describe '#updated_at' do
      it 'defaults to nil' do
        expect(Tag.new.updated_at).to be_nil
      end
    end
  end

  describe 'name validation' do
    it 'requires a name to be present' do
      expect(Tag.make(:name => nil)).to fail_validation_for(:name)
    end

    it 'requires name to be unique' do
      name = Sham.random
      Tag.make!(:name => name)
      expect(Tag.make(:name => name)).to fail_validation_for(:name)
    end

    it 'compares names in a case-insensitive manner' do
      name = Sham.random
      Tag.make!(:name => name.upcase)
      expect(Tag.make(:name => name.downcase)).to fail_validation_for(:name)
    end

    it 'accepts names containing only letters' do
      expect(Tag.make!(:name => 'foobar')).to be_valid
    end

    it 'accepts names consisting of multiple words separated by a period' do
      expect(Tag.make!(:name => 'foo.bar')).to be_valid
      expect(Tag.make!(:name => 'foo.bar.baz')).to be_valid
    end

    it 'accepts names containing numbers' do
      expect(Tag.make(:name => 'foo100')).to be_valid
    end

    it 'rejects names containing spaces' do
      expect(Tag.make(:name => 'foo bar')).to fail_validation_for(:name)
      expect(Tag.make(:name => 'foo bar baz')).to fail_validation_for(:name)
    end

    it 'rejects names starting with leading periods' do
      expect(Tag.make(:name => '.foo')).to fail_validation_for(:name)
      expect(Tag.make(:name => '..foo')).to fail_validation_for(:name)
    end

    it 'rejects names ending with trailing periods' do
      expect(Tag.make(:name => 'foo.')).to fail_validation_for(:name)
      expect(Tag.make(:name => 'foo..')).to fail_validation_for(:name)
    end

    it 'rejects names containing consecutive periods' do
      expect(Tag.make(:name => 'foo..bar')).to fail_validation_for(:name)
      expect(Tag.make(:name => 'foo...bar')).to fail_validation_for(:name)
    end

    it 'rejects names containing other punctuation' do
      expect(Tag.make(:name => 'foo,bar')).to fail_validation_for(:name)
      expect(Tag.make(:name => 'foo-bar')).to fail_validation_for(:name)
    end
  end

  describe 'name normalization' do
    it 'normalizes names to lowercase upon creation' do
      name = Sham.random.upcase
      tag = Tag.make(:name => name)
      expect(tag.name).to eq(name.downcase)
    end

    it 'normalizes names when updating attributes via the accessor' do
      name = Sham.random
      tag = Tag.make!
      tag.name = name.upcase
      expect(tag.name).to eq(name.downcase)
    end
  end

  describe '#find_with_tag_names' do
    before do
      @foo = Tag.make! :name => 'foo'
      @bar = Tag.make! :name => 'bar'
      @baz = Tag.make! :name => 'baz'
    end

    it 'finds single tags' do
      expect(Tag.find_with_tag_names('foo')).to eq([@foo])
    end

    it 'finds multiple tags' do
      expect(Tag.find_with_tag_names('foo', 'bar', 'baz')).to match_array([@foo, @bar, @baz])
    end

    it 'returns an empty array when no matching tags' do
      expect(Tag.find_with_tag_names('roy')).to eq([])
    end

    it 'ignores blank parameters' do
      expect(Tag.find_with_tag_names('foo', nil, ' ')).to eq([@foo])
      expect(Tag.find_with_tag_names(nil)).to eq([])
      expect(Tag.find_with_tag_names()).to eq([])
    end
  end

  describe '#to_param' do
    it 'returns the name' do
      expect(Tag.make!(:name => 'foo').to_param).to eq('foo')
    end

    context 'new record' do
      it 'returns nil' do
        expect(Tag.new.to_param).to be_nil
      end
    end

    context 'dirty record' do
      it 'returns the old (in the database) name' do
        tag = Tag.make! :name => 'foo'
        tag.name = 'bar'
        expect(tag.to_param).to eq('foo')
      end
    end
  end

  describe '.tags_reachable_from_tags' do
    before do
      Article.make!      # no tags
      Issue.make!        # no tags
      Article.make!.tag  'nginx'
      Article.make!.tag  'nginx updates'
      Article.make!.tag  'nginx updates'
      Article.make!.tag  'nginx security updates'
      Article.make!.tag  'nginx'
      Article.make!.tag  'nginx security'
      Article.make!.tag  'nginx mac.os.x'
      Post.make!.tag     'nginx'
      Post.make!.tag     'ruby'
      Post.make!.tag     'nginx'
      Post.make!.tag     'nginx updates'
      Post.make!.tag     'nginx ssl'
      Post.make!.tag     'nginx'
      Issue.make!.tag    'security'
      Issue.make!.tag    'crash'
      Issue.make!.tag    'security crash'
      @nginx    = Tag.find_by_name 'nginx'
      @updates  = Tag.find_by_name 'updates'
      @security = Tag.find_by_name 'security'
      @macosx   = Tag.find_by_name 'mac.os.x'
      @ruby     = Tag.find_by_name 'ruby'
      @ssl      = Tag.find_by_name 'ssl'
      @crash    = Tag.find_by_name 'crash'
    end

    it 'returns empty array for no tags' do
      expect(Tag.tags_reachable_from_tags).to eq([])
    end

    it 'returns empty array for more than 5 tags' do
      expect(Tag.tags_reachable_from_tags(Tag.make!, Tag.make!, Tag.make!, Tag.make!, Tag.make!, Tag.make!)).to eq([])
    end

    it 'returns empty array for non-existent tag (singular)' do
      fake_tag    = Tag.make
      fake_tag.id = 78321
      expect(Tag.tags_reachable_from_tags(fake_tag)).to eq([])
    end

    it 'complains if passed nil tag' do
      expect { Tag.tags_reachable_from_tags(nil) }.to raise_error
    end

    it 'returns empty array for non-existent tags (plural)' do
      fake1     = Tag.make
      fake1.id  = 98712
      fake2     = Tag.make
      fake2.id  = 34510
      expect(Tag.tags_reachable_from_tags(fake1, fake2)).to eq([])
    end

    it 'returns tag objects for "top-level" search' do
      expected = [@updates, @security, @macosx, @ssl]
      expect(Tag.tags_reachable_from_tags(@nginx)).to match_array(expected)
      expect(Tag.tags_reachable_from_tags(@ssl)).to eq([@nginx])
      expect(Tag.tags_reachable_from_tags(@crash)).to eq([@security])
    end

    it 'returns tag objects for "second level" search' do
      expect(Tag.tags_reachable_from_tags(@nginx, @security)).to eq([@updates])
    end

    it 'accepts an array rather than a list of parameters' do
      # this makes things easier for callers
      expect(Tag.tags_reachable_from_tags([@nginx, @security])).to eq([@updates])
    end

    it 'excludes starting tags from returned results' do
      # tested implicitly above, but test explicitly here anyway
      expect(Tag.tags_reachable_from_tags(@nginx)).not_to include(@nginx)
    end

    it 'returns empty array when no more results' do
      expect(Tag.tags_reachable_from_tags(@nginx, @security, @updates)).to eq([])
    end
  end

  describe '.tags_reachable_from_tag_names' do
    before do
      Article.make!      # no tags
      Issue.make!        # no tags
      Article.make!.tag  'nginx'
      Article.make!.tag  'nginx updates'
      Article.make!.tag  'nginx updates'
      Article.make!.tag  'nginx security updates'
      Article.make!.tag  'nginx'
      Article.make!.tag  'nginx security'
      Article.make!.tag  'nginx mac.os.x'
      Post.make!.tag     'nginx'
      Post.make!.tag     'ruby'
      Post.make!.tag     'nginx'
      Post.make!.tag     'nginx updates'
      Post.make!.tag     'nginx ssl'
      Post.make!.tag     'nginx'
      Issue.make!.tag    'security'
      Issue.make!.tag    'crash'
      Issue.make!.tag    'security crash'
      @nginx    = Tag.find_by_name 'nginx'
      @updates  = Tag.find_by_name 'updates'
      @security = Tag.find_by_name 'security'
      @macosx   = Tag.find_by_name 'mac.os.x'
      @ruby     = Tag.find_by_name 'ruby'
      @ssl      = Tag.find_by_name 'ssl'
      @crash    = Tag.find_by_name 'crash'
    end

    it 'returns empty array for no tags' do
      expect(Tag.tags_reachable_from_tag_names).to eq([])
    end

    it 'returns empty array for more than 5 tags' do
      expect(Tag.tags_reachable_from_tag_names('foo', 'bar', 'baz', 'bing', 'bong', 'bang')).to eq([])
    end

    it 'returns empty array for non-existent tag (singular)' do
      expect(Tag.tags_reachable_from_tag_names('gibberish')).to eq([])
    end

    it 'complains if passed nil tag name' do
      expect { Tag.tags_reachable_from_tag_names(nil) }.to raise_error
    end

    it 'returns empty array for non-existent tags (plural)' do
      expect(Tag.tags_reachable_from_tag_names('gibberish', 'splinkel')).to eq([])
    end

    it 'returns tag objects for "top-level" search' do
      expected = [@updates, @security, @macosx, @ssl]
      expect(Tag.tags_reachable_from_tag_names('nginx')).to match_array(expected)
      expect(Tag.tags_reachable_from_tag_names('ssl')).to eq([@nginx])
      expect(Tag.tags_reachable_from_tag_names('crash')).to eq([@security])
    end

    it 'returns tag objects for "second level" search' do
      expect(Tag.tags_reachable_from_tag_names('nginx', 'security')).to eq([@updates])
    end

    it 'excludes starting tags from returned results' do
      # tested implicitly above, but test explicitly here anyway
      expect(Tag.tags_reachable_from_tag_names('nginx')).not_to include(@nginx)
    end

    it 'returns empty array when no more results' do
      expect(Tag.tags_reachable_from_tag_names('nginx', 'security', 'updates')).to eq([])
    end
  end
end
