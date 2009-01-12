require File.dirname(__FILE__) + '/../spec_helper'
require File.join(File.dirname(__FILE__), '..', 'lib', 'active_record', 'acts', 'shared_classifiable_spec')

describe Comment do
  it 'should be valid' do
    create_comment.should be_valid
  end

  # we test a value larger than the default MySQL TEXT size (65535)
  it 'should support body content of over 128K' do
    # make sure the long body survives the round-trip from the db
    length = 128 * 1024
    long_body = 'x' * length
    comment = create_comment :body => long_body
    comment.body.length.should == length
    comment.reload
    comment.body.length.should == length
  end
end

describe Comment, 'acting as classifiable ("moderate_as_spam!" method)' do
  before do
    @object = create_comment :awaiting_moderation => true
  end

  it_should_behave_like 'ActiveRecord::Acts::Classifiable "moderate_as_spam!" method'
end

describe Comment, 'acting as classifiable ("moderate_as_ham!" method)' do
  before do
    @object = create_comment :awaiting_moderation => true
  end

  it_should_behave_like 'ActiveRecord::Acts::Classifiable "moderate_as_ham!" method'
end

describe Comment, '"send_new_comment_alert" method' do
  before do
    @comment = new_comment :user => (create_user :superuser => false)
  end

  it 'should fire after saving new records' do
    @comment.should_receive(:send_new_comment_alert)
    @comment.save
  end

  it 'should not fire after saving an existing record' do
    @comment.save
    @comment.should_not_receive(:send_new_comment_alert)
    @comment.save
  end

  it 'should deliver a new comment alert for normal user comments' do
    CommentMailer.should_receive(:deliver_new_comment_alert).with(@comment)
    @comment.save
  end

  it 'should deliver a new comment alert for anonymous comments' do
    comment = new_comment :user => nil
    CommentMailer.should_receive(:deliver_new_comment_alert).with(comment)
    comment.save
  end

  it 'should not send comment alerts for superuser comments' do
    comment = new_comment :user => (create_user :superuser => true)
    CommentMailer.should_not_receive(:deliver_new_comment_alert)
    comment.save
  end

  it 'should rescue exceptions rather than dying' do
    CommentMailer.should_receive(:deliver_new_comment_alert).and_raise('fatal error!')
    lambda { @comment.save }.should_not raise_error
  end

  it 'should log an error message on failure' do
    CommentMailer.stub!(:deliver_new_comment_alert).and_raise('fatal error!')
    @comment.logger.should_receive(:error)
    @comment.save
  end
end
