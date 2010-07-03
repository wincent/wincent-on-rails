require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Tagging do
  it 'should be valid' do
    Tagging.make.should be_valid
  end
end

describe Tagging, 'grouped_taggables_for_tag method' do
  it 'should return last-updated models first' do
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

describe Tagging, 'grouped_taggables_for_tag_names' do
  it 'should return last-updated models first' do
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
