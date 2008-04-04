require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'commentable.rb'

describe Commentable, :shared => true do

  # seems that as this is a shared block I can't use a "before" block here
  # (records persist in the database across examples)
  def set_up_comments
    @comment1 = add_comment :awaiting_moderation => false, :spam => false, :public => false
    @comment2 = add_comment :awaiting_moderation => false, :spam => true,  :public => true
    @comment3 = add_comment :awaiting_moderation => false, :spam => false, :public => true
    @comment4 = add_comment :awaiting_moderation => false, :spam => true,  :public => false
    @comment5 = add_comment :awaiting_moderation => true,  :spam => false, :public => true
    @comment6 = add_comment :awaiting_moderation => true,  :spam => false, :public => false
  end

  def add_comment overrides = {}
    comment = @commentable.comments.build :body => String.random
    overrides.each { |k,v| comment.send("#{k.to_s}=", v) }
    comment.save
    comment
  end

  it 'should find comments in ascending (chronological) order by creation date' do
    @commentable.comments.each do |comment|
      Comment.update_all ['created_at = ?', comment.id.days.ago], ['id = ?', comment.id]
    end
    @commentable.reload.comments.collect(&:id).should == @commentable.comments.collect(&:id).sort.reverse
  end

  it 'should find all published comments' do
    set_up_comments
    @commentable.comments.published.collect(&:id).sort.should == [@comment3.id]
  end

  it 'should find all unmoderated comments' do
    # "unmoderated" means :awaiting_moderation => true, :spam => false
    set_up_comments
    @commentable.comments.unmoderated.collect(&:id).sort.should == [@comment5, @comment6].collect(&:id).sort
  end

  it 'should find all ham comments' do
    # all comments which have not been flagged as spam (both moderated and unmoderated)
    set_up_comments
    @commentable.comments.ham.collect(&:id).sort.should == [@comment1, @comment3, @comment5, @comment6].collect(&:id).sort
  end

  it 'should find all spam comments' do
    set_up_comments
    @commentable.comments.spam.collect(&:id).sort.should == [@comment2, @comment4].collect(&:id).sort
  end

  it 'should report the count of published comments' do
    # the count of all published (not awaiting moderation, not flagged as spam) comments
    set_up_comments
    @commentable.comments.published_count.should == 1
  end

  it 'should report the count of unmoderated comments' do
    set_up_comments
    @commentable.comments.unmoderated_count.should == 2
  end

  it 'should report the count of ham comments' do
    set_up_comments
    @commentable.comments.ham_count.should == 4
  end

  it 'should report the count of spam comments' do
    set_up_comments
    @commentable.comments.spam_count.should == 2
  end
end
