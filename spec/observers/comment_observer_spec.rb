require 'spec_helper'

describe CommentObserver do
  describe 'sending a new comment alert' do
    let(:user)    { User.make! :superuser => false }
    let(:comment) { Comment.make :user => user }

    it 'delivers an alert after saving a new comment' do
      mock(CommentMailer).new_comment_alert(comment).stub!.deliver_now
      comment.save
    end

    it 'does not deliver an alert after re-saving an existing record' do
      comment.save
      do_not_allow(CommentMailer).new_comment_alert
      comment.save
    end

    it 'delivers an alert for anonymous comments' do
      comment = Comment.make :user => nil
      mock(CommentMailer).new_comment_alert(comment).stub!.deliver_now
      comment.save
    end

    it 'does not deliver an alert for superuser comments' do
      comment = Comment.make :user => (User.make! :superuser => true)
      do_not_allow(CommentMailer).new_comment_alert
      comment.save
    end

    it 'rescues exceptions rather than dying' do
      mock(CommentMailer).new_comment_alert(comment) { raise 'fatal error!' }
      lambda { comment.save }.should_not raise_error
    end

    it 'logs an error message on failure' do
      mock(CommentMailer).new_comment_alert(comment) { raise 'fatal error!' }
      mock(Rails.logger).error(/fatal error!/)
      comment.save
    end
  end
end
