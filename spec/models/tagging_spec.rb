require 'spec_helper'

describe Tagging do
  describe 'attributes' do
    describe '#tag_id' do
      it 'defaults to nil' do
        expect(Tagging.new.tag_id).to be_nil
      end
    end

    describe '#taggable_id' do
      it 'defaults to nil' do
        expect(Tagging.new.taggable_id).to be_nil
      end
    end

    describe '#taggable_type' do
      it 'defaults to nil' do
        expect(Tagging.new.taggable_type).to be_nil
      end
    end

    describe '#created_at' do
      it 'defaults to nil' do
        expect(Tagging.new.created_at).to be_nil
      end
    end

    describe '#updated_at' do
      it 'defaults to nil' do
        expect(Tagging.new.updated_at).to be_nil
      end
    end
  end

  describe 'accessible attibutes' do
    #subject { Tagging.make }
    #it { should allow_mass_assignment_of :tag_id => Tag.make!.id }
    #it { should allow_mass_assignment_of :taggable_id => Post.make!.id }
    #it { should allow_mass_assignment_of :taggable_type => 'Post' }
  end

  describe 'grouped_taggables_for_tag method' do
    it 'returns last-updated models first' do
      @old_post = Post.make!
      @new_post = Post.make!
      @old_post.tag('foo')
      @new_post.tag('foo')
      Post.where(id: @old_post).update_all(['created_at = ?, updated_at = ?', 6.days.ago, 5.days.ago])
      @tag = Tag.find_by_name 'foo'
      groups = Tagging.grouped_taggables_for_tag(@tag, nil)
      expect(groups.first.taggables).to eq([@new_post, @old_post])
    end
  end

  describe 'grouped_taggables_for_tag_names method' do
    it 'returns last-updated models first' do
      @old_post = Post.make!
      @new_post = Post.make!
      @old_post.tag('foo', 'bar')
      @new_post.tag('foo', 'bar')
      Post.where(id: @old_post).update_all(['created_at = ?, updated_at = ?', 6.days.ago, 5.days.ago])
      groups = Tagging.grouped_taggables_for_tag_names(['foo', 'bar'], nil)
      expect(groups[1].first.taggables).to eq([@new_post, @old_post])
    end
  end
end
