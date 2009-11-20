require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'commentable'

describe Commentable, :shared => true do

  # seems that as this is a shared block I can't use a "before" block here
  # (records persist in the database across examples)
  def set_up_comments
    @comment1 = add_comment :awaiting_moderation => false, :public => false
    @comment2 = add_comment :awaiting_moderation => false, :public => true
    @comment3 = add_comment :awaiting_moderation => false, :public => true
    @comment4 = add_comment :awaiting_moderation => false, :public => false
    @comment5 = add_comment :awaiting_moderation => true,  :public => true
    @comment6 = add_comment :awaiting_moderation => true,  :public => false
  end

  def add_comment overrides = {}
    comment = @commentable.comments.build :body => FR::random_string
    overrides.each { |k,v| comment.send("#{k.to_s}=", v) }
    comment.save
    comment
  end

  it 'should find comments in ascending (chronological) order by creation date' do
    set_up_comments
    @commentable.comments.each do |comment|
      Comment.update_all ['created_at = ?', comment.id.days.ago], ['id = ?', comment.id]
    end
    @commentable.reload.comments.should =~ @commentable.comments
  end

  it 'should find all published comments' do
    set_up_comments
    @commentable.comments.published.should =~ [@comment2, @comment3]
  end

  it 'should find all unmoderated comments' do
    # "unmoderated" means :awaiting_moderation => true
    set_up_comments
    @commentable.comments.unmoderated.should =~ [@comment5, @comment6]
  end

  it 'should find all ham comments' do
    # all comments (both moderated and unmoderated)
    set_up_comments
    @commentable.comments.ham.should =~ [@comment1, @comment2, @comment3, @comment4, @comment5, @comment6]
  end

  it 'should report the count of published comments' do
    # the count of all published (not awaiting moderation) comments
    set_up_comments
    @commentable.comments.published_count.should == 2
  end

  it 'should report the count of unmoderated comments' do
    set_up_comments
    @commentable.comments.unmoderated_count.should == 2
  end

  it 'should report the count of ham comments' do
    set_up_comments
    @commentable.comments.ham_count.should == 6
  end

  it 'should update the comments_count cache when a comment is added and not held for moderation (ie. admin comments)' do
    @commentable.comments_count.should == 0
    add_comment :awaiting_moderation => false
    @commentable.reload
    @commentable.comments_count.should == 1
  end

  it 'should not update the comments_count cache when a comment is added and held for moderation' do
    @commentable.comments_count.should == 0
    add_comment :awaiting_moderation => true
    @commentable.reload
    @commentable.comments_count.should == 0
  end

  it 'should update the comments_count cache when a comment is added and moderated as ham' do
    @commentable.comments_count.should == 0
    comment = add_comment :awaiting_moderation => true
    @commentable.reload
    @commentable.comments_count.should == 0
    comment.moderate_as_ham!
    @commentable.reload
    @commentable.comments_count.should == 1
  end

  it 'should update the comments_count cache when a ham comment is later destroyed' do
    @commentable.comments_count.should == 0
    comment = add_comment :awaiting_moderation => true
    @commentable.reload
    @commentable.comments_count.should == 0
    comment.moderate_as_ham!
    @commentable.reload
    @commentable.comments_count.should == 1
    comment.destroy
    @commentable.reload
    @commentable.comments_count.should == 0
  end

  # TODO: also check that last_commenter field is correctly updated
end

# ie. issues, forum topics
describe Commentable, "updating timestamps for comment changes", :shared => true do
  def add_comment overrides = {}
    comment = @commentable.comments.build :body => FR::random_string
    overrides.each { |k,v| comment.send("#{k.to_s}=", v) }
    comment.save
    comment
  end

  # BUG: topic and issue work differently, can't use the same spec for both
  # this is probably codesmell, the fact that I have to write different tests
  # once again i'm thinking about whether topic should have no "body" element and just a "comment" object attached from the start
  #it 'should have a nil timestamp when there are no comments' do
  #  @commentable.comments.should be_empty
  #  @commentable.last_commented_at.to_s.should == @commentable.updated_at.to_s
  #end

  it 'should use the comment timestamp when a comment is added and is not held for moderation (ie. admin comments)' do
    @commentable.comments.should be_empty
    comment = add_comment :awaiting_moderation => false
    @commentable.reload
    @commentable.updated_at.to_s.should == comment.updated_at.to_s
  end

  it 'should not update the timestamp when a comment is added and held for moderation' do
    @commentable.comments.should be_empty
    start_date = @commentable.updated_at
    add_comment :awaiting_moderation => true
    @commentable.reload
    @commentable.updated_at.to_s.should == start_date.to_s
  end

  it 'should update the timestamp when a comment is added and is moderated as ham' do
    @commentable.comments.should be_empty
    start_date = @commentable.updated_at
    comment = add_comment :awaiting_moderation => true
    @commentable.reload
    @commentable.updated_at.to_s.should == start_date.to_s
    comment.moderate_as_ham!
    @commentable.reload
    @commentable.updated_at.to_s.should == comment.updated_at.to_s
  end

  it 'should amend the timestamp when a ham comment is later destroyed' do
    @commentable.comments.should be_empty
    start_date = @commentable.updated_at
    comment = add_comment :awaiting_moderation => true
    @commentable.reload
    @commentable.updated_at.to_s.should == start_date.to_s
    comment.moderate_as_ham!
    @commentable.reload
    @commentable.updated_at.to_s.should == comment.updated_at.to_s
    comment.destroy
    @commentable.reload
    @commentable.updated_at.to_s.should == start_date.to_s
  end
end

# ie. blog posts, wiki articles
describe Commentable, "not updating timestamps for comment changes", :shared => true do
  def add_comment overrides = {}
    comment = @commentable.comments.build :body => FR::random_string
    overrides.each { |k,v| comment.send("#{k.to_s}=", v) }
    comment.save
    comment
  end

  # BUG: see corresponding comment above about different behaviour in Issues and Topics
  #it 'should have a nil timestamp when there are no comments'

  it 'should use the commentable updated timestamp when a comment is added and is not held for moderation (ie. admin comments)' do
    @commentable.comments.should be_empty
    start_date = @commentable.updated_at
    comment = add_comment :awaiting_moderation => false
    @commentable.reload
    @commentable.updated_at.to_s.should == start_date.to_s
  end

  it 'should use the commentable updated timestamp when a comment is added and held for moderation' do
    @commentable.comments.should be_empty
    start_date = @commentable.updated_at
    add_comment :awaiting_moderation => true
    @commentable.reload
    @commentable.updated_at.to_s.should == start_date.to_s
  end

  it 'should use the commentable updated timestamp when a comment is added and is moderated as ham' do
    @commentable.comments.should be_empty
    start_date = @commentable.updated_at
    comment = add_comment :awaiting_moderation => true
    @commentable.reload
    @commentable.updated_at.to_s.should == start_date.to_s
    comment.moderate_as_ham!
    @commentable.reload
    @commentable.updated_at.to_s.should == start_date.to_s
  end

  it 'should use the commentable updated timestamp when a ham comment is later destroyed' do
    @commentable.comments.should be_empty
    start_date = @commentable.updated_at
    comment = add_comment :awaiting_moderation => true
    @commentable.reload
    @commentable.updated_at.to_s.should == start_date.to_s
    comment.moderate_as_ham!
    @commentable.reload
    @commentable.updated_at.to_s.should == start_date.to_s
    comment.destroy
    @commentable.reload
    @commentable.updated_at.to_s.should == start_date.to_s
  end
end
