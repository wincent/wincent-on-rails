require 'spec_helper'

describe Topic do
  describe 'attributes' do
    describe '#title' do
      it 'defaults to nil' do
        expect(Topic.new.title).to be_nil
      end
    end

    describe '#body' do
      it 'defaults to nil' do
        expect(Topic.new.body).to be_nil
      end
    end

    describe '#forum_id' do
      it 'defaults to nil' do
        expect(Topic.new.forum_id).to be_nil
      end
    end

    describe '#user_id' do
      it 'defaults to nil' do
        expect(Topic.new.user_id).to be_nil
      end
    end

    describe '#public' do
      it 'defaults to true' do
        expect(Topic.new.public).to eq(true)
      end
    end

    describe '#accepts_comments' do
      it 'defaults to true' do
        expect(Topic.new.accepts_comments).to eq(true)
      end
    end

    describe '#awaiting_moderation' do
      it 'defaults to true' do
        expect(Topic.new.awaiting_moderation).to eq(true)
      end
    end

    describe '#comments_count' do
      it 'defaults to zero' do
        expect(Topic.new.comments_count).to be_zero
      end
    end

    describe '#view_count' do
      it 'defaults to zero' do
        expect(Topic.new.view_count).to be_zero
      end
    end

    describe '#created_at' do
      it 'defaults to nil' do
        expect(Topic.new.created_at).to be_nil
      end
    end

    describe '#updated_at' do
      it 'defaults to nil' do
        expect(Topic.new.updated_at).to be_nil
      end
    end

    describe '#last_commenter_id' do
      it 'defaults to nil' do
        expect(Topic.new.last_commenter_id).to be_nil
      end
    end

    describe '#last_comment_id' do
      it 'defaults to nil' do
        expect(Topic.new.last_comment_id).to be_nil
      end
    end

    describe '#last_commented_at' do
      it 'defaults to nil' do
        expect(Topic.new.last_commented_at).to be_nil
      end
    end
  end

  it 'should be valid' do
    expect(Topic.make).to be_valid
  end

  it 'should update timestamps for comment changes' do
    expect(Topic.update_timestamps_for_comment_changes?).to eq(true)
  end

  # we test a value larger than the default MySQL TEXT size (65535)
  it 'should support body content of over 128K' do
    # make sure the long body survives the round-trip from the db
    long_body = ('x' * 127 + ' ') * 1024
    topic = Topic.make! body: long_body
    expect(topic.body.length).to eq(long_body.length)
    topic.reload
    expect(topic.body.length).to eq(long_body.length)
  end

  it_has_behavior '#moderate_as_ham!' do
    let(:model) { Topic.make! awaiting_moderation: true }
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
    expect(Topic.make(body: nil)).to fail_validation_for(:body)
  end

  it 'should complain if longer than 128k' do
    long_body = 'x' * (128 * 1024 + 100)
    expect(Topic.make(body: long_body)).to fail_validation_for(:body)
  end
end

describe Topic, 'creation' do
  it 'should default to being public' do
    expect(Topic.create.public).to eq(true)
  end

  it 'should default to accepting comments' do
    expect(Topic.create.accepts_comments).to eq(true)
  end

  it 'should default to awaiting moderation' do
    expect(Topic.create.awaiting_moderation).to eq(true)
  end
end

describe Topic, 'forum association' do
  before do
    @forum = Forum.make!
    @topic = add_topic
  end

  def add_topic
    @forum.topics.create title: Sham.random, body: Sham.random
  end

  it 'should belong to a forum' do
    expect(@topic.forum).to eq(@forum)
  end

  it 'should employ a counter cache' do
    # Rails counter cache updates the database but not the value in the current instance, so must re-fetch it for comparison
    start = @forum.reload.topics_count
    add_topic
    stop  = @forum.reload.topics_count
    expect(stop - start).to eq(1)
  end
end

describe Topic, 'user association' do
  it 'should belong to a user' do
    user  = User.make!
    topic = user.topics.new
    expect(topic.user).to eq(user)
  end
end

describe Topic, '"last commenter" association' do
  before do
    @topic = Topic.make!
  end

  it 'should belong to a last commenter' do
    @user = User.make!
    @comment = @topic.comments.new body: Sham.random # can't set user here (protected)
    @comment.user = @user
    @comment.save
    @comment.moderate_as_ham! # only here does the last commenter actually get set
    expect(@topic.reload.last_commenter).to eq(@user)
  end

  it 'should return nil if no last commenter' do
    expect(@topic.last_commenter).to be_nil
  end
end

describe Topic, 'comments association' do
  before do
    @topic = Topic.make!
  end

  def add_comment
    comment = @topic.comments.create body: Sham.random
  end

  it 'should have many comments' do
    expect {
      10.times { add_comment }
      @topic.reload
    }.to change(@topic.comments, :length).by(10)
  end

  it 'should order comments in ascending order by creation date' do
    10.times do
      comment = add_comment
      Comment.where(id: comment).update_all(['updated_at = ?', comment.id.days.from_now])
    end
    expect(@topic.comments.pluck(:id)).to eq(Comment.order('created_at').pluck(:id))
  end

  it 'should destroy dependent comments when destroying' do
    10.times { add_comment }
    expect { @topic.destroy }.to change(Comment, :count).by(-10)
  end
end

describe Topic, '"find_topics_for_forum" method' do
  before do
    @display_name = Sham.random
    @user         = User.make! display_name: @display_name
    @topic        = Topic.make! awaiting_moderation: false
    @forum        = @topic.forum
  end

  def add_comment overrides = {}
    comment = @topic.comments.new body: Sham.random
    comment.awaiting_moderation = false
    overrides.each { |k,v| comment.send("#{k.to_s}=", v) }
    comment.save!
    comment
  end

  it 'should select the topic id' do
    expect(Topic.find_topics_for_forum(@forum).first.id).to eq(@topic.id)
  end

  it 'should select the topic title' do
    expect(Topic.find_topics_for_forum(@forum).first.title).to eq(@topic.title)
  end

  it 'should select the comments count' do
    expect(Topic.find_topics_for_forum(@forum).first.comments_count).to eq(@topic.comments_count)
  end

  it 'should select the view count' do
    expect(Topic.find_topics_for_forum(@forum).first.view_count).to eq(@topic.view_count)
  end

  it 'should select the update date' do
    # we lose some precision here, so call to_s to make the comparison pass
    # otherwise, Thu Apr 03 18:30:09 +0200 2008
    #        and Thu Apr 03 18:30:09 +0200 2008
    # might not be considered equal
    expect(Topic.find_topics_for_forum(@forum).first.updated_at.to_s).to eq(@topic.updated_at.to_s)
  end

  it 'should select the last comment id (when available)' do
    comment = add_comment
    expect(Topic.find_topics_for_forum(@forum).first.last_comment_id).to eq(comment.id)
  end

  it 'should select nil for the last comment id (when not available)' do
    expect(Topic.find_topics_for_forum(@forum).first.last_comment_id).to be_nil
  end

  it 'should select the last active user id (when a comment has been posted)' do
    # we're using find_by_sql here, so Rails returns a String, hence the to_i
    comment = add_comment user: @user
    expect(Topic.find_topics_for_forum(@forum).first.last_active_user_id.to_i).to eq(@user.id)
  end

  it 'should select the last active user id (when no comments have been posted)' do
    topic = Topic.make! user: @user, awaiting_moderation: false
    expect(Topic.find_topics_for_forum(topic.forum).first.last_active_user_id.to_i).to eq(@user.id)
  end

  it 'should return nil last active user id for anonymous commenters' do
    comment = add_comment user: nil
    expect(Topic.find_topics_for_forum(@forum).first.last_active_user_id).to eq(nil)
  end

  it 'should return nil last active user id for anonymous topic posters (nil)' do
    topic = Topic.make! user: nil, awaiting_moderation: false
    expect(Topic.find_topics_for_forum(topic.forum).first.last_active_user_id).to eq(nil)
  end

  it 'should select the last active user displayname (when a comment has been posted)' do
    comment = add_comment user: @user
    expect(Topic.find_topics_for_forum(@forum).first.last_active_user_display_name).to eq(@user.display_name)
  end

  it 'should select the last active user displayname (when no comments have been posted)' do
    topic = Topic.make! user: @user, awaiting_moderation: false
    expect(Topic.find_topics_for_forum(topic.forum).first.last_active_user_display_name).to eq(@user.display_name)
  end

  it 'should return nil last active user displayname for anonymous commenters' do
    comment = add_comment user: nil
    expect(Topic.find_topics_for_forum(@forum).first.last_active_user_display_name).to eq(nil)
  end

  it 'should return nil last active user displayname for anonymous topic posters' do
    topic = Topic.make! user: nil, awaiting_moderation: false
    expect(Topic.find_topics_for_forum(topic.forum).first.last_active_user_display_name).to eq(nil)
  end

  it 'should find only topics which have already passed moderation' do
    @topic.update_attribute(:awaiting_moderation, true)
    expect(Topic.find_topics_for_forum(@forum)).to eq([])
  end

  it 'should find only topics which are public' do
    @topic.update_attribute(:public, false)
    expect(Topic.find_topics_for_forum(@forum)).to eq([])
  end

  it 'should order the results by update date in descending order' do
    forum = Forum.make!
    10.times do
      topic = Topic.make! forum: forum
      Topic.where(id: topic).update_all(['updated_at = ?', topic.id.days.from_now])
    end
    topic_ids = Topic.find_topics_for_forum(forum).collect(&:id)
    expect(topic_ids).to eq(topic_ids.sort.reverse)
  end

  it 'should include topics even if they have no comments' do
    @topic.comments.each(&:destroy)
    expect(Topic.find_topics_for_forum(@forum).length).to eq(1)
  end

  it 'should respect the offset and limit parameters' do
    forum = Forum.make!
    topic_ids = []
    100.times do
      topic = Topic.make! forum: forum, awaiting_moderation: false
      topic_ids << topic.id
      Topic.where(id: topic).update_all(['updated_at = ?', topic.id.days.from_now])
    end
    expect(Topic.find_topics_for_forum(forum, 10, 30).collect(&:id)).to eq(topic_ids.reverse[10..39]) # 30 records
  end

  it 'should default to an offset of 0' do
    expect(Topic.find_topics_for_forum(@forum).first).to eq(@topic)
  end

  it 'should default to a limit of 20' do
    forum = Forum.make!
    100.times { Topic.make! forum: forum, awaiting_moderation: false }
    expect(Topic.find_topics_for_forum(forum).length).to eq(20)
  end

  it 'should return nothing when there are no topics' do
    @forum.topics.delete_all
    expect(Topic.find_topics_for_forum(@forum)).to eq([])
  end
end

# was formerly a test of the "visible_comments" method
# that method was deleted and replaced with "comments.published"
# keep the specs in place to confirm that the behaviour is the same
describe Topic, '"comments.published"' do
  before do
    @topic    = Topic.make!    awaiting_moderation: false
    @comment1 = add_comment_with_override :awaiting_moderation, false
    @comment2 = add_comment_with_override :awaiting_moderation, true
    # @comment3 (was a comment with the "spam" attribute set, but that attribute no longer exists)
    @comment4 = add_comment_with_override :public, false
    @comment5 = add_comment_with_override :awaiting_moderation, false
  end

  def add_comment_with_override attribute, val
    comment = @topic.comments.create body: Sham.random
    comment.update_attribute attribute, val
    comment
  end

  it 'should find all published comments' do
    expect(@topic.comments.published.to_a).to match_array([@comment1, @comment5])
  end

  it 'should order results by comment creation date in ascending order' do
    Comment.where(id: @comment1).update_all(['created_at = ?', 7.days.ago])
    Comment.where(id: @comment5).update_all(['created_at = ?', 3.days.ago])
    expect(@topic.comments.published.pluck(:id)).to eq([@comment1.id, @comment5.id])
  end
end

describe Topic, '"hit!" method' do
  it 'should increment the view counter' do
    # Rails increment_counter updates the database but not the value in the current instance, so must re-fetch it for comparison
    topic = Topic.make!
    start = topic.view_count
    topic.hit!
    stop = topic.reload.view_count
    expect(stop - start).to eq(1)
  end
end

describe Topic, 'send_new_topic_alert callback' do
  before do
    @topic = Topic.make user: (User.make! superuser: false)
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
    mock(TopicMailer).new_topic_alert(anything).stub!.deliver_now
    @topic.save
  end

  it 'should deliver a new topic alert for anonymous topics' do
    topic = Topic.make user: nil
    mock(TopicMailer).new_topic_alert(anything).stub!.deliver_now
    topic.save
  end

  it 'should not send topic alerts for superuser topics' do
    topic = Topic.make user: (User.make! superuser: true)
    do_not_allow(TopicMailer).new_topic_alert
    topic.save
  end

  it 'should rescue exceptions rather than dying' do
    stub(TopicMailer).new_topic_alert(anything) { raise 'fatal error!' }
    expect { @topic.save }.not_to raise_error
  end

  it 'should log an error message on failure' do
    stub(TopicMailer).new_topic_alert(anything) { raise 'fatal error!' }
    mock(@topic.logger).error(/fatal error/)
    @topic.save
  end
end
