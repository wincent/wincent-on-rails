require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  it 'should be valid' do
    create_comment.should be_valid
  end
end

describe Comment, '"moderate_as_spam!" method' do
  before do
    @comment = create_comment :awaiting_moderation => true
  end

  it 'should turn off the "awaiting moderation" flag' do
    lambda { @comment.moderate_as_spam! }.should change(@comment, :awaiting_moderation).from(true).to(false)
  end

  it 'should change the "awaiting moderation" flag in the database' do
    @comment.moderate_as_spam!
    Comment.find(@comment.id).awaiting_moderation.should == @comment.awaiting_moderation
  end

  it 'should turn on the "spam" flag' do
    lambda { @comment.moderate_as_spam! }.should change(@comment, :spam).from(false).to(true)
  end

  it 'should change the "spam" flag in the database' do
    @comment.moderate_as_spam!
    Comment.find(@comment.id).spam.should == @comment.spam
  end

  it 'should not alter the comment "updated at" timestamp' do
    lambda { @comment.moderate_as_spam! }.should_not change(@comment, :updated_at)
  end

  it 'should not change the "updated at" timestamp in the database' do
    # as seems to be usual with ActiveRecord round-tripping, we lose precision and so must do a "to_s"
    @comment.moderate_as_spam!
    Comment.find(@comment.id).updated_at.to_s.should == @comment.updated_at.to_s
  end
end

describe Comment, '"moderate_as_ham!" method' do
  before do
    @comment = create_comment :awaiting_moderation => true
  end

  it 'should turn off the "awaiting moderation" flag' do
    lambda { @comment.moderate_as_ham! }.should change(@comment, :awaiting_moderation).from(true).to(false)
  end

  it 'should change the "awaiting moderation" flag in the database' do
    @comment.moderate_as_ham!
    Comment.find(@comment.id).awaiting_moderation.should == @comment.awaiting_moderation
  end

  it 'should turn off the "spam" flag' do
    # the spam flag starts as "off" by default anyway
    @comment.moderate_as_ham!
    @comment.spam.should == false
  end

  it 'should change the "spam" flag in the database' do
    @comment.moderate_as_ham!
    Comment.find(@comment.id).spam.should == @comment.spam
  end

  it 'should not alter the comment "updated at" timestamp' do
    lambda { @comment.moderate_as_ham! }.should_not change(@comment, :updated_at)
  end

  it 'should not change the "updated at" timestamp in the database' do
    # as seems to be usual with ActiveRecord round-tripping, we lose precision and so must do a "to_s"
    @comment.moderate_as_ham!
    Comment.find(@comment.id).updated_at.to_s.should == @comment.updated_at.to_s
  end
end

describe Comment, '"send_new_comment_alert" method' do
  it 'should fire after saving new records' do
    comment = new_comment
    comment.should_receive(:send_new_comment_alert)
    comment.save
  end

  it 'should not fire after saving an existing record' do
    comment = create_comment
    comment.should_not_receive(:send_new_comment_alert)
    comment.save
  end

  it 'should deliver a new comment alert' do
    comment = new_comment
    CommentMailer.should_receive(:deliver_new_comment_alert).with(comment)
    comment.save
  end

  it 'should rescue exceptions rather than dying' do
    comment = new_comment
    CommentMailer.should_receive(:deliver_new_comment_alert).and_raise('fatal error!')
    lambda { comment.save }.should_not raise_error
  end

  it 'should log an error message on failure' do
    comment = new_comment
    CommentMailer.stub!(:deliver_new_comment_alert).and_raise('fatal error!')
    comment.logger.should_receive(:error)
    comment.save
  end
end
