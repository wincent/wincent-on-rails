require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'active_record', 'acts', 'shared_taggable_spec')
require File.join(File.dirname(__FILE__), '..', 'lib', 'shared_commentable_spec')

describe Topic do
  it 'should be valid' do
    new_topic.should be_valid
  end

  it 'should update timestamps for comment changes' do
    Topic.update_timestamps_for_comment_changes?.should == true
  end
end

describe Topic, 'creation' do
  it 'should default to being public' do
    create_topic.public.should == true
  end

  it 'should default to accepting comments' do
    create_topic.accepts_comments.should == true
  end

  it 'should default to awaiting moderation' do
    create_topic.awaiting_moderation.should == true
  end

  it 'should default to being considered as ham (non-spam)' do
    create_topic.spam.should == false
  end
end

describe Topic, 'forum association' do
  before do
    @forum = create_forum
    @topic = add_topic
  end

  def add_topic
    @forum.topics.create :title => String.random, :body => String.random
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
    @user   = create_user
    @topic  = create_topic
    @user.topics << @topic
    @topic.user.should == @user
  end
end

describe Topic, '"last commenter" association' do
  before do
    @topic = create_topic
  end

  it 'should belong to a last commenter' do
    @user = create_user
    @comment = @topic.comments.build :body => String.random # can't set user here (protected)
    @comment.user = @user
    @comment.save
    @topic.reload.last_commenter.should == @user
  end

  it 'should return nil if no last commenter' do
    @topic.last_commenter.should be_nil
  end
end

describe Topic, 'comments association' do
  before do
    @topic = create_topic
  end

  def add_comment
    comment = @topic.comments.create :body => String.random
  end

  it 'should have many comments' do
    lambda {
      10.times { add_comment }
      @topic.reload
    }.should change(@topic.comments, :length).by(10)
  end

  it 'should order comments in descending order by update date' do
    10.times do
      comment = add_comment
      Comment.update_all ['updated_at = ?', comment.id.days.from_now], ['id = ?', comment.id]
    end
    @topic.comments.collect(&:id).should == Comment.find(:all, :order => 'updated_at DESC').collect(&:id)
  end

  it 'should destroy dependent comments when destroying' do
    10.times { add_comment }
    lambda { @topic.destroy }.should change(Comment, :count).by(-10)
  end
end

describe Topic, 'acting as commentable' do
  before do
    @commentable = create_topic
  end

  it_should_behave_like 'Commentable'
end

describe Topic, 'acting as taggable' do
  before do
    @object     = create_topic
    @new_object = new_topic
  end

  it_should_behave_like 'ActiveRecord::Acts::Taggable'
end

describe Topic, '"find_topics_for_forum" method' do
  before do
    @display_name = String.random
    @user         = create_user :display_name => @display_name
    @topic        = create_topic :awaiting_moderation => false
    @forum        = @topic.forum
  end

  def add_comment overrides = {}
    comment = @topic.comments.build :body => String.random
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
    topic = create_topic :user => @user, :awaiting_moderation => false
    Topic.find_topics_for_forum(topic.forum).first.last_active_user_id.to_i.should == @user.id
  end

  it 'should return nil last active user id for anonymous commenters' do
    comment = add_comment :user => nil
    Topic.find_topics_for_forum(@forum).first.last_active_user_id.should == nil
  end

  it 'should return nil last active user id for anonymous topic posters (nil)' do
    topic = create_topic :user => nil, :awaiting_moderation => false
    Topic.find_topics_for_forum(topic.forum).first.last_active_user_id.should == nil
  end
  
  it 'should select the last active user displayname (when a comment has been posted)' do
    comment = add_comment :user => @user
    Topic.find_topics_for_forum(@forum).first.last_active_user_display_name.should == @user.display_name
  end

  it 'should select the last active user displayname (when no comments have been posted)' do
    topic = create_topic :user => @user, :awaiting_moderation => false
    Topic.find_topics_for_forum(topic.forum).first.last_active_user_display_name.should == @user.display_name
  end

  it 'should return nil last active user displayname for anonymous commenters' do
    comment = add_comment :user => nil
    Topic.find_topics_for_forum(@forum).first.last_active_user_display_name.should == nil
  end

  it 'should return nil last active user displayname for anonymous topic posters' do
    topic = create_topic :user => nil, :awaiting_moderation => false
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

  it 'should find only topics which are not marked as spam' do
    @topic.update_attribute(:spam, true)
    Topic.find_topics_for_forum(@forum).should == []
  end

  it 'should order the results by update date in descending order' do
    forum = create_forum
    10.times do
      topic = create_topic :forum => forum
      Topic.update_all ['updated_at = ?', topic.id.days.from_now], ['id = ?', topic.id]
    end
    topic_ids = Topic.find_topics_for_forum(forum).collect(&:id)
    topic_ids.should == topic_ids.sort
  end

  it 'should include topics even if they have no comments' do
    @topic.comments.each(&:destroy)
    Topic.find_topics_for_forum(@forum).length.should == 1
  end

  it 'should respect the offset and limit parameters' do
    forum = create_forum
    topic_ids = []
    100.times do
      topic = create_topic :forum => forum, :awaiting_moderation => false
      topic_ids << topic.id
      Topic.update_all ['updated_at = ?', topic.id.days.from_now], ['id = ?', topic.id]
    end
    Topic.find_topics_for_forum(forum, 10, 30).collect(&:id).should == topic_ids.reverse[10..39] # 30 records
  end

  it 'should default to an offset of 0' do
    Topic.find_topics_for_forum(@forum).first.should == @topic
  end

  it 'should default to a limit of 20' do
    forum = create_forum
    100.times { create_topic :forum => forum, :awaiting_moderation => false }
    Topic.find_topics_for_forum(forum).length.should == 20
  end

  it 'should return nothing when there are no topics' do
    @forum.topics.delete_all
    Topic.find_topics_for_forum(@forum).should == []
  end
end
=begin
conditions = { :public => true, :awaiting_moderation => false, :spam => false, :commentable_id => self.id, :commentable_type => 'Topic' }
Comment.find :all, :conditions => conditions, :include => 'user', :order => 'comments.created_at'
=end

describe Topic, '"visible_comments" method' do
  before do
    @topic    = create_topic    :awaiting_moderation => false
    @comment1 = add_comment_with_override :awaiting_moderation, false
    @comment2 = add_comment_with_override :awaiting_moderation, true
    @comment3 = add_comment_with_override :spam, true
    @comment4 = add_comment_with_override :public, false
    @comment5 = add_comment_with_override :awaiting_moderation, false
  end

  def add_comment_with_override attribute, val
    comment = @topic.comments.create
    comment.update_attribute attribute, val
    comment
  end

  it 'should find all published comments' do
    @topic.visible_comments.collect(&:id).sort.should == [@comment1, @comment5].collect(&:id).sort
  end

  it 'should order results by comment creation date in descending order' do
    Comment.update_all ['created_at = ?', 3.days.ago], ['id = ?', @comment1.id]
    Comment.update_all ['created_at = ?', 7.days.ago], ['id = ?', @comment5.id]
    @topic.visible_comments.collect(&:id).should == [@comment1.id, @comment5.id]
  end
end

describe Topic, '"hit!" method' do
  it 'should increment the view counter' do
    # Rails increment_counter updates the database but not the value in the current instance, so must re-fetch it for comparison
    topic = create_topic
    start = topic.view_count
    topic.hit!
    stop = topic.reload.view_count
    (stop - start).should == 1
  end
end
