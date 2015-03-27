require 'spec_helper'

describe Comment do
  describe '#body' do
    it 'defaults to nil' do
      Comment.new.body.should be_nil
    end
  end

  describe '#user_id' do
    it 'defaults to nil' do
      Comment.new.user_id.should be_nil
    end
  end

  describe '#commentable_id' do
    it 'defaults to nil' do
      Comment.new.commentable_id.should be_nil
    end
  end

  describe '#commentable_type' do
    it 'defaults to nil' do
      Comment.new.commentable_type.should be_nil
    end
  end

  describe '#awaiting_moderation' do
    it 'defaults to true' do
      Comment.new.awaiting_moderation.should == true
    end
  end

  describe '#public' do
    it 'defaults to true' do
      Comment.new.public.should == true
    end
  end

  describe '#created_at' do
    it 'defaults to nil' do
      Comment.new.created_at.should be_nil
    end
  end

  describe '#updated_at' do
    it 'defaults to nil' do
      Comment.new.updated_at.should be_nil
    end
  end

  it 'should be valid' do
    Comment.make!.should be_valid
  end

  # we test a value larger than the default MySQL TEXT size (65535)
  it 'should support body content of over 128K' do
    # make sure the long body survives the round-trip from the db
    length = 128 * 1024
    long_body = 'x' * length
    comment = Comment.make! :body => long_body
    comment.body.length.should == length
    comment.reload
    comment.body.length.should == length
  end

  it_has_behavior '#moderate_as_ham!' do
    let(:model) { Comment.make! :awaiting_moderation => true }
  end
end

describe Comment, 'validating the body' do
  it 'should require it to be present' do
    Comment.make(:body => nil).should fail_validation_for(:body)
  end

  it 'should complain if longer than 128k' do
    long_body = 'x' * (128 * 1024 + 100)
    Comment.make(:body => long_body).should fail_validation_for(:body)
  end
end
