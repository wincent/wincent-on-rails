require File.dirname(__FILE__) + '/../spec_helper'

describe Tagging do
  before(:each) do
    @tagging = Tagging.new
  end

  it "should be valid" do
    @tagging.should be_valid
  end
end

describe Tagging, 'grouped_taggables_for_tag method' do
  it 'should return last-updated models first' do
    @old_post = create_post
    @new_post = create_post
    @old_post.tag('foo')
    @new_post.tag('foo')
    Post.update_all ['created_at = ?, updated_at = ?', 6.days.ago, 5.days.ago],
      ["id = #{@old_post.id}"]
    @tag = Tag.find_by_name 'foo'
    groups = Tagging.grouped_taggables_for_tag(@tag, nil)
    groups.first.taggables.should == [@new_post, @old_post]
  end
end

describe Tagging, 'grouped_taggables_for_tag_names' do
  it 'should return last-updated models first' do
    @old_post = create_post
    @new_post = create_post
    @old_post.tag('foo', 'bar')
    @new_post.tag('foo', 'bar')
    Post.update_all ['created_at = ?, updated_at = ?', 6.days.ago, 5.days.ago],
      ["id = #{@old_post.id}"]
    groups = Tagging.grouped_taggables_for_tag_names(['foo', 'bar'], nil)
    groups[1].first.taggables.should == [@new_post, @old_post]
  end
end
