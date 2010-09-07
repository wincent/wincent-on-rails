require 'spec_helper'

describe Tagging do
  describe 'attributes' do
    describe '#tag_id' do
      it 'defaults to nil' do
        Tagging.new.tag_id.should be_nil
      end
    end

    describe '#taggable_id' do
      it 'defaults to nil' do
        Tagging.new.taggable_id.should be_nil
      end
    end

    describe '#taggable_type' do
      it 'defaults to nil' do
        Tagging.new.taggable_type.should be_nil
      end
    end

    describe '#created_at' do
      it 'defaults to nil' do
        Tagging.new.created_at.should be_nil
      end
    end

    describe '#updated_at' do
      it 'defaults to nil' do
        Tagging.new.updated_at.should be_nil
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
      Post.update_all ['created_at = ?, updated_at = ?', 6.days.ago, 5.days.ago],
        ["id = #{@old_post.id}"]
      @tag = Tag.find_by_name 'foo'
      groups = Tagging.grouped_taggables_for_tag(@tag, nil)
      groups.first.taggables.should == [@new_post, @old_post]
    end
  end

  describe 'grouped_taggables_for_tag_names method' do
    it 'returns last-updated models first' do
      @old_post = Post.make!
      @new_post = Post.make!
      @old_post.tag('foo', 'bar')
      @new_post.tag('foo', 'bar')
      Post.update_all ['created_at = ?, updated_at = ?', 6.days.ago, 5.days.ago],
        ["id = #{@old_post.id}"]
      groups = Tagging.grouped_taggables_for_tag_names(['foo', 'bar'], nil)
      groups[1].first.taggables.should == [@new_post, @old_post]
    end
  end
end
