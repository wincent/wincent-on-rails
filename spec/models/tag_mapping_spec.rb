require 'spec_helper'

describe TagMapping do
  before do
    TagMapping.destroy_all
    Rails.cache.delete(TagMapping::CACHE_KEY)
  end

  describe '.alias' do
    it 'creates a new mapping' do
      instance = TagMapping.alias('foo', 'bar')
      expect(instance).to be_a(TagMapping)
      expect(instance.tag_name).to eq('foo')
      expect(instance.canonical_tag_name).to eq('bar')
      expect(instance.new_record?).to eq(false)
    end

    context 'with a prexisting mapping' do
      it 'complains' do
        expect { 2.times { TagMapping.alias('foo', 'bar') } }.
          to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end

  describe '.canonicalize!' do
    let(:tag1) { Tag.make! }
    let(:tag2) { Tag.make! }
    let(:tag3) { Tag.make! }
    let(:article1) { Article.make! }
    let(:article2) { Article.make! }

    before do
      Tagging.destroy_all # makes the math a little easier below
      expect { article1.tag tag1.name }.to change { tag1.reload.taggings_count }.by(1)
      expect { article2.tag tag2.name }.to change { tag2.reload.taggings_count }.by(1)
    end

    context 'when there are no collisions' do
      before { TagMapping.alias(tag1.name, tag3.name) }

      it 'updates problematic tags' do
        TagMapping.canonicalize!
        expect(article1.reload.tag_names).to eq([tag3.name])
        expect(article2.reload.tag_names).to eq([tag2.name])
      end

      it 'updates tagging count on tags' do
        expect { TagMapping.canonicalize! }.
          to change { [
            tag1.reload.taggings_count, # -1
            tag2.reload.taggings_count, # 0
            tag3.reload.taggings_count, # +1
            Tagging.count,              # 0
          ] }.
          from([1, 1, 0, 2]).
          to([0, 1, 1, 2])
      end
    end

    context 'when the canonical mapping already exists on the target' do
      before do
        article1.tag tag2.name
        TagMapping.alias(tag1.name, tag2.name)
      end

      it 'removes the problematic tags' do
        TagMapping.canonicalize!
        expect(article1.reload.tag_names).to eq([tag2.name])
        expect(article2.reload.tag_names).to eq([tag2.name])
      end

      it 'updates the tagging count on tags' do
        expect { TagMapping.canonicalize! }.
          to change { [
            tag1.reload.taggings_count, # -1
            tag2.reload.taggings_count, # 0
            Tagging.count               # -1
          ] }.
          from([1, 2, 3]).
          to([0, 2, 2])
      end
    end
  end

  describe 'mappings' do
    it 'returns a hash' do
      TagMapping.alias('foo', 'bar')
      TagMapping.alias('upgrades', 'updates')
      expect(TagMapping.mappings).to eq({
        'foo' => 'bar',
        'upgrades' => 'updates',
      })
    end

    it 'caches' do
      TagMapping.alias('foo', 'bar')
      call_count = 0
      mock.proxy(TagMapping).connection { |c| call_count += 1; c }
      TagMapping.mappings
      expect(call_count).to eq(1)
      TagMapping.mappings
      expect(call_count).to eq(1)
    end

    # Effectively testing TagMappingObserver here, but that's ok.
    it 'invalidates the cache when creating a new mapping' do
      TagMapping.alias('foo', 'bar')
      expect { TagMapping.alias('upgrades', 'updates') }.
        to change { TagMapping.mappings }.
        from({ 'foo' => 'bar' }).
        to({ 'foo' => 'bar', 'upgrades' => 'updates' })
    end

    it 'invalidates the cache when deleting an existing mapping' do
      mapping = TagMapping.alias('foo', 'bar')
      expect { mapping.destroy }.
        to change { TagMapping.mappings }.
        from({ 'foo' => 'bar' }).
        to({})
    end

    it 'invalidates the cache when updating an existing mapping' do
      mapping = TagMapping.alias('foo', 'bar')
      expect { mapping.update_attribute(:tag_name, 'xyz')}.
        to change { TagMapping.mappings }.
        from({ 'foo' => 'bar' }).
        to({ 'xyz' => 'bar' })
    end

    context 'when there are no mappings' do
      it 'returns an empty hash' do
        expect(TagMapping.mappings).to eq({})
      end
    end
  end
end
