require 'spec_helper'

describe Topic do
  describe 'attributes' do
    describe '#title' do
      it 'defaults to nil' do
        Topic.new.title.should be_nil
      end
    end

    describe '#body' do
      it 'defaults to nil' do
        Topic.new.body.should be_nil
      end
    end

    describe '#forum_id' do
      it 'defaults to nil' do
        Topic.new.forum_id.should be_nil
      end
    end

    describe '#user_id' do
      it 'defaults to nil' do
        Topic.new.user_id.should be_nil
      end
    end

    describe '#public' do
      it 'defaults to true' do
        Topic.new.public.should be_true
      end
    end

    describe '#accepts_comments' do
      it 'defaults to true' do
        Topic.new.accepts_comments.should be_true
      end
    end

    describe '#awaiting_moderation' do
      it 'defaults to true' do
        Topic.new.awaiting_moderation.should be_true
      end
    end

    describe '#comments_count' do
      it 'defaults to zero' do
        Topic.new.comments_count.should be_zero
      end
    end

    describe '#view_count' do
      it 'defaults to zero' do
        Topic.new.view_count.should be_zero
      end
    end

    describe '#created_at' do
      it 'defaults to nil' do
        Topic.new.created_at.should be_nil
      end
    end

    describe '#updated_at' do
      it 'defaults to nil' do
        Topic.new.updated_at.should be_nil
      end
    end

    describe '#last_commenter_id' do
      it 'defaults to nil' do
        Topic.new.last_commenter_id.should be_nil
      end
    end

    describe '#last_comment_id' do
      it 'defaults to nil' do
        Topic.new.last_comment_id.should be_nil
      end
    end

    describe '#last_commented_at' do
      it 'defaults to nil' do
        Topic.new.last_commented_at.should be_nil
      end
    end
  end

  it 'should be valid' do
    Topic.make.should be_valid
  end

  it 'should update timestamps for comment changes' do
    Topic.update_timestamps_for_comment_changes?.should == true
  end

  # we test a value larger than the default MySQL TEXT size (65535)
  it 'should support body content of over 128K' do
    # make sure the long body survives the round-trip from the db
    length = 128 * 1024
    long_body = 'x' * length
    topic = Topic.make! :body => long_body
    topic.body.length.should == length
    topic.reload
    topic.body.length.should == length
  end

  it_has_behavior '#moderate_as_ham!' do
    let(:model) { Topic.make! :awaiting_moderation => true }
  end

  let(:commentable) { Topic.make! }
  it_has_behavior 'commentable'
  it_has_behavior 'commentable (updating timestamps for comment changes)'

  it_has_behavior 'taggable' do
    let(:model) { Topic.make! }
    let(:new_model) { Topic.make }
  end
end

describe Topic, 'validating the body' do
  it 'should require it to be present' do
    Topic.make(:body => nil).should fail_validation_for(:body)
  end

  it 'should complain if longer than 128k' do
    long_body = 'x' * (128 * 1024 + 100)
    Topic.make(:body => long_body).should fail_validation_for(:body)
  end
end

describe Topic, 'creation' do
  it 'should default to being public' do
    Topic.create.public.should == true
  end

  it 'should default to accepting comments' do
    Topic.create.accepts_comments.should == true
  end

  it 'should default to awaiting moderation' do
    Topic.create.awaiting_moderation.should == true
  end
end

describe Topic, 'forum association' do
  before do
    @forum = Forum.make!
    @topic = add_topic
  end

  def add_topic
    @forum.topics.create :title => Sham.random, :body => Sham.random
  end

  it 'should belong to a forum' do
    @topic.forum.should == @forum
  end

  it 'should employ a counter cache' do
    # Rails counter cache updates the database but not the value in the current instance, so must re-fetch it for comparison
    start = @forum.reload.topics_count
    add_topic
    stop  = @forum.reload.topics_count
    (stop - start).should == 1
  end
end

describe Topic, 'user association' do
  it 'should belong to a user' do
    @user   = User.make!
    @topic  = Topic.make!
    @user.topics << @topic
    @topic.user.should == @user
  end
end

describe Topic, '"last commenter" association' do
  before do
    @topic = Topic.make!
  end

  it 'should belong to a last commenter' do
    @user = User.make!
    @comment = @topic.comments.new :body => Sham.random # can't set user here (protected)
    @comment.user = @user
    @comment.save
    @comment.moderate_as_ham! # only here does the last commenter actually get set
    @topic.reload.last_commenter.should == @user
  end

  it 'should return nil if no last commenter' do
    @topic.last_commenter.should be_nil
  end
end

describe Topic, 'comments association' do
  before do
    @topic = Topic.make!
  end

  def add_comment
    comment = @topic.comments.create :body => Sham.random
  end

  it 'should have many comments' do
    lambda {
      10.times { add_comment }
      @topic.reload
    }.should change(@topic.comments, :length).by(10)
  end

  it 'should order comments in ascending order by creation date' do
    10.times do
      comment = add_comment
      Comment.update_all ['updated_at = ?', comment.id.days.from_now], ['id = ?', comment.id]
    end
    @topic.comments.collect(&:id).should == Comment.find(:all, :order => 'created_at').collect(&:id)
  end

  it 'should destroy dependent comments when destroying' do
    10.times { add_comment }
    lambda { @topic.destroy }.should change(Comment, :count).by(-10)
  end
end

describe Topic, '"find_topics_for_forum" method' do
  before do
    @display_name = Sham.random
    @user         = User.make! :display_name => @display_name
    @topic        = Topic.make! :awaiting_moderation => false
    @forum        = @topic.forum
  end

  def add_comment overrides = {}
    comment = @topic.comments.new :body => Sham.random
    comment.awaiting_moderation = false
    overrides.each { |k,v| comment.send("#{k.to_s}=", v) }
    comment.save!
    comment
  end

  it 'should select the topic id' do
    Topic.find_topics_for_forum(@forum).first.id.should == @topic.id
  end

  it 'should select the topic title' do
    Topic.find_topics_for_forum(@forum).first.title.should == @topic.title
  end

  it 'should select the comments count' do
    Topic.find_topics_for_forum(@forum).first.comments_count.should == @topic.comments_count
  end

  it 'should select the view count' do
    Topic.find_topics_for_forum(@forum).first.view_count.should == @topic.view_count
  end

  it 'should select the update date' do
    # we lose some precision here, so call to_s to make the comparison pass
    # otherwise, Thu Apr 03 18:30:09 +0200 2008
    #        and Thu Apr 03 18:30:09 +0200 2008
    # might not be considered equal
    Topic.find_topics_for_forum(@forum).first.updated_at.to_s.should == @topic.updated_at.to_s
  end

  it 'should select the last comment id (when available)' do
    comment = add_comment
    Topic.find_topics_for_forum(@forum).first.last_comment_id.should == comment.id
  end

  it 'should select nil for the last comment id (when not available)' do
    Topic.find_topics_for_forum(@forum).first.last_comment_id.should be_nil
  end

  it 'should select the last active user id (when a comment has been posted)' do
    # we're using find_by_sql here, so Rails returns a String, hence the to_i
    comment = add_comment :user => @user
    Topic.find_topics_for_forum(@forum).first.last_active_user_id.to_i.should == @user.id
  end

  it 'should select the last active user id (when no comments have been posted)' do
    topic = Topic.make! :user => @user, :awaiting_moderation => false
    Topic.find_topics_for_forum(topic.forum).first.last_active_user_id.to_i.should == @user.id
  end

  it 'should return nil last active user id for anonymous commenters' do
    comment = add_comment :user => nil
    Topic.find_topics_for_forum(@forum).first.last_active_user_id.should == nil
  end

  it 'should return nil last active user id for anonymous topic posters (nil)' do
    topic = Topic.make! :user => nil, :awaiting_moderation => false
    Topic.find_topics_for_forum(topic.forum).first.last_active_user_id.should == nil
  end

  it 'should select the last active user displayname (when a comment has been posted)' do
    comment = add_comment :user => @user
    Topic.find_topics_for_forum(@forum).first.last_active_user_display_name.should == @user.display_name
  end

  it 'should select the last active user displayname (when no comments have been posted)' do
    topic = Topic.make! :user => @user, :awaiting_moderation => false
    Topic.find_topics_for_forum(topic.forum).first.last_active_user_display_name.should == @user.display_name
  end

  it 'should return nil last active user displayname for anonymous commenters' do
    comment = add_comment :user => nil
    Topic.find_topics_for_forum(@forum).first.last_active_user_display_name.should == nil
  end

  it 'should return nil last active user displayname for anonymous topic posters' do
    topic = Topic.make! :user => nil, :awaiting_moderation => false
    Topic.find_topics_for_forum(topic.forum).first.last_active_user_display_name.should == nil
  end

  it 'should find only topics which have already passed moderation' do
    @topic.update_attribute(:awaiting_moderation, true)
    Topic.find_topics_for_forum(@forum).should == []
  end

  it 'should find only topics which are public' do
    @topic.update_attribute(:public, false)
    Topic.find_topics_for_forum(@forum).should == []
  end

  it 'should order the results by update date in descending order' do
    forum = Forum.make!
    10.times do
      topic = Topic.make! :forum => forum
      Topic.update_all ['updated_at = ?', topic.id.days.from_now], ['id = ?', topic.id]
    end
    topic_ids = Topic.find_topics_for_forum(forum).collect(&:id)
    topic_ids.should == topic_ids.sort.reverse
  end

  it 'should include topics even if they have no comments' do
    @topic.comments.each(&:destroy)
    Topic.find_topics_for_forum(@forum).length.should == 1
  end

  it 'should respect the offset and limit parameters' do
    forum = Forum.make!
    topic_ids = []
    100.times do
      topic = Topic.make! :forum => forum, :awaiting_moderation => false
      topic_ids << topic.id
      Topic.update_all ['updated_at = ?', topic.id.days.from_now], ['id = ?', topic.id]
    end
    Topic.find_topics_for_forum(forum, 10, 30).collect(&:id).should == topic_ids.reverse[10..39] # 30 records
  end

  it 'should default to an offset of 0' do
    Topic.find_topics_for_forum(@forum).first.should == @topic
  end

  it 'should default to a limit of 20' do
    forum = Forum.make!
    100.times { Topic.make! :forum => forum, :awaiting_moderation => false }
    Topic.find_topics_for_forum(forum).length.should == 20
  end

  it 'should return nothing when there are no topics' do
    @forum.topics.delete_all
    Topic.find_topics_for_forum(@forum).should == []
  end
end

# was formerly a test of the "visible_comments" method
# that method was deleted and replaced with "comments.published"
# keep the specs in place to confirm that the behaviour is the same
describe Topic, '"comments.published"' do
  before do
    @topic    = Topic.make!    :awaiting_moderation => false
    @comment1 = add_comment_with_override :awaiting_moderation, false
    @comment2 = add_comment_with_override :awaiting_moderation, true
    # @comment3 (was a comment with the "spam" attribute set, but that attribute no longer exists)
    @comment4 = add_comment_with_override :public, false
    @comment5 = add_comment_with_override :awaiting_moderation, false
  end

  def add_comment_with_override attribute, val
    comment = @topic.comments.create :body => Sham.random
    comment.update_attribute attribute, val
    comment
  end

  it 'should find all published comments' do
    @topic.comments.published.to_a.should =~ [@comment1, @comment5]
  end

  it 'should order results by comment creation date in ascending order' do
    Comment.update_all ['created_at = ?', 7.days.ago], ['id = ?', @comment1.id]
    Comment.update_all ['created_at = ?', 3.days.ago], ['id = ?', @comment5.id]
    @topic.comments.published.collect(&:id).should == [@comment1.id, @comment5.id]
  end
end

describe Topic, '"hit!" method' do
  it 'should increment the view counter' do
    # Rails increment_counter updates the database but not the value in the current instance, so must re-fetch it for comparison
    topic = Topic.make!
    start = topic.view_count
    topic.hit!
    stop = topic.reload.view_count
    (stop - start).should == 1
  end
end

describe Topic, 'send_new_topic_alert callback' do
  before do
    @topic = Topic.make :user => (User.make! :superuser => false)
  end

  it 'should fire after saving new records' do
    mock(@topic).send_new_topic_alert
    @topic.save
  end

  it 'should not fire after saving an existing record' do
    @topic.save
    do_not_allow(@topic).send_new_topic_alert
    @topic.save
  end

  it 'should deliver a new topic alert for normal user topics' do
    mock(TopicMailer).new_topic_alert(anything).stub!.deliver
    @topic.save
  end

  it 'should deliver a new topic alert for anonymous topics' do
    topic = Topic.make :user => nil
    mock(TopicMailer).new_topic_alert(anything).stub!.deliver
    topic.save
  end

  it 'should not send topic alerts for superuser topics' do
    topic = Topic.make :user => (User.make! :superuser => true)
    do_not_allow(TopicMailer).new_topic_alert
    topic.save
  end

  it 'should rescue exceptions rather than dying' do
    stub(TopicMailer).new_topic_alert(anything) { raise 'fatal error!' }
    lambda { @topic.save }.should_not raise_error
  end

  it 'should log an error message on failure' do
    stub(TopicMailer).new_topic_alert(anything) { raise 'fatal error!' }
    mock(@topic.logger).error(/fatal error/)
    @topic.save
  end
end
