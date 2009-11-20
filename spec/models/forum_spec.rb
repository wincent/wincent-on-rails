require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Forum do
  it 'should be valid' do
    new_forum.should be_valid
  end
end

describe Forum, 'creation' do
  it 'should default to being public' do
    create_forum.public.should == true
  end

  it 'should auto-populate the "position" attribute upon creation' do
    create_forum(:position => nil).position.should_not be_nil
  end

  it 'should by default appear at the end of the list' do
    first   = create_forum
    second  = create_forum
    second.position.should > first.position
  end
end

describe Forum, 'topics association' do
  before do
    @forum = create_forum
  end

  def add_topic
    @forum.topics.create :title => FR::random_string, :body => FR::random_string
  end

  it 'should have many topics' do
    10.times { add_topic }
    @forum.topics.length.should == 10
  end

  it 'should order topics in descending order by update date' do
    10.times do
      topic = add_topic
      Topic.update_all ['updated_at = ?', topic.id.days.from_now], ['id = ?', topic.id]
    end
    @forum.topics.collect(&:id).should == Topic.find(:all, :order => 'updated_at DESC').collect(&:id)
  end

  it 'should destroy dependent topics when destroying' do
    10.times { add_topic }
    lambda { @forum.destroy }.should change(Topic, :count).by(-10)
  end
end

# :name, :description
describe Forum, 'accessible attributes' do
  it 'should allow mass-assignment of the name' do
    new_forum.should allow_mass_assignment_of(:name => FR::random_string)
  end

  it 'should allow mass-assignment of the description' do
    new_forum.should allow_mass_assignment_of(:description => FR::random_string)
  end
end

# :topics_count, :position, :public
describe Forum, 'protected attributes' do
  it 'should deny mass-assignment of the topics count' do
    new_forum(:topics_count => 50).should_not allow_mass_assignment_of(:topics_count => 100)
  end

  it 'should deny mass-assignment of the position' do
    new_forum(:position => 50).should_not allow_mass_assignment_of(:position => 100)
  end

  it 'should deny mass-assignment of the "public" attribute' do
    new_forum(:public => true).should_not allow_mass_assignment_of(:public => false)
  end
end

describe Forum, 'validating the name' do
  it 'should require it to be present' do
     new_forum(:name => nil).should fail_validation_for(:name)
  end

  it 'should allow letters and spaces' do
    words = Array.new(10).collect {|i| FR::random_string }
    new_forum(:name => words.join(' ')).should_not fail_validation_for(:name)
  end

  it 'should disallow punctuation' do
    new_forum(:name => 'foo.bar').should fail_validation_for(:name)
  end

  it 'should require it to be unique' do
    name = 'foo'
    create_forum :name => name
    new_forum(:name => name).should fail_validation_for(:name)
  end
end

describe Forum, 'parametrization' do
  it 'should convert spaces into hyphens' do
    Forum.parametrize('foo bar').should == 'foo-bar'
  end

  it 'should downcase' do
    Forum.parametrize('FooBAR').should == 'foobar'
  end

  it 'should use the name as the param, with spaces converted into hyphens' do
    new_forum(:name => 'foo bar').to_param.should == 'foo-bar'
  end
end

describe Forum, 'deparametrization' do
  it 'should convert hyphens into spaces' do
    Forum.deparametrize('foo-bar').should == 'foo bar'
  end
end

describe Forum, 'find_with_param! method' do
  before do
    @name   = 'foo bar'
    @forum  = create_forum :name => @name
  end

  it 'should find by name' do
    Forum.should_receive(:find_by_name!).and_return(@forum)
    Forum.find_with_param!(@name)
  end

  it 'should handle hyphens in the name' do
    Forum.find_with_param!('foo-bar').should == @forum
  end

  it 'should by case agnostic' do
    Forum.find_with_param!('FoO-baR').should == @forum
  end

  it 'should complain if not found' do
    lambda { Forum.find_with_param!('non-existent') }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it 'should accept and use optional conditions such as ":public => true" (public forum)' do
    Forum.find_with_param!('foo-bar', :public => true).should == @forum
  end

  it 'should accept and use optional conditions such as ":public => true" (private forum)' do
    private_forum = create_forum :name => 'baz', :public => false
    Forum.find_with_param!('baz', :public => false).should == private_forum
    lambda { Forum.find_with_param!('baz', :public => true) }.should raise_error(ActiveRecord::RecordNotFound)
  end
end

describe Forum, 'find_all method' do
  before do
    @forum = create_forum
  end

  def add_topic
    create_topic :forum => @forum
  end

  it 'should find forums with topics' do
    add_topic
    Forum.find_all.size.should == 1
  end

  it 'should find forums with no topics' do
    Forum.find_all.size.should == 1
  end

  it 'should select the forum id' do
    Forum.find_all.first.id.should == @forum.id
  end

  it 'should select the forum name' do
    Forum.find_all.first.name.should == @forum.name
  end

  it 'should select the forum description' do
    Forum.find_all.first.description.should == @forum.description
  end

  it 'should select the topics cont' do
    Forum.find_all.first.topics_count.should == @forum.topics_count
  end

  it 'should select the "last active topic date"' do
    topic1 = add_topic
    topic2 = add_topic
    topic3 = add_topic
    timestamp = 2.days.from_now
    Topic.update_all ['updated_at = ?', timestamp], ['id = ?', topic2.id]

    # there is some weirdness here because the find_all method uses find_by_sql
    # this means that datetime columns are returned as String objects, hence the need for Time.parse
    # note also that we lose some precision doing the Time.parse, and must call to_s in order for the comparison to succeed
    Time.parse(Forum.find_all.first.last_active_at).to_s.should == timestamp.to_s
  end

  it 'should return nil for missing "last active topic date"' do
    Forum.find_all.first.last_active_at.should be_nil
  end

  it 'should select the "last active topic id"' do
    topic1 = add_topic
    topic2 = add_topic
    topic3 = add_topic
    Topic.update_all ['updated_at = ?', 2.days.from_now], ['id = ?', topic2.id]
    Forum.find_all.first.last_topic_id.should == topic2.id.to_s
  end

  it 'should return nil for missing "last active topic id"' do
    Forum.find_all.first.last_topic_id.should be_nil
  end

  it 'should order results by the "position" attribute' do
    @forum.update_attribute :position, 1
    forum1 = create_forum :position => 15
    forum2 = create_forum :position => 5
    forum3 = create_forum :position => 10
    Forum.find_all.collect(&:id).should == [@forum, forum2, forum3, forum1].collect(&:id)
  end

  it 'should find only public forums' do
    start = Forum.find_all.length
    @forum.update_attribute(:public, false)
    finish = Forum.find_all.length
    (finish - start).should == -1
  end

  # was a bug
  it 'should not count a topic awaiting moderation as a "last active" topic' do
    topic = add_topic
    topic.awaiting_moderation = true
    topic.save
    Forum.find_all.first.last_topic_id.should be_nil
  end

  it 'should not allow a topic awaiting moderation to influence the "updated at" field' do
    topic = add_topic
    topic.awaiting_moderation = true
    topic.save
    Forum.find_all.first.last_active_at.should be_nil
  end

  it 'should not count a private topic as a "last active" topic' do
    topic = add_topic
    topic.public = false
    topic.save
    Forum.find_all.first.last_topic_id.should be_nil
  end

  it 'should not allow a private topic to influence the "updated at" field' do
    topic = add_topic
    topic.public = false
    topic.save
    Forum.find_all.first.last_active_at.should be_nil
  end
end

# "last post" info wrong for anonymous comments?
describe Forum, 'http://rails.wincent.com/issues/671' do
  before do
    @forum    = create_forum
    @user     = create_user
    @replier  = create_user
  end

  # note with all these specs we test after deletion as well as after creation
  it 'should show the correct "last post" for topics with no replies' do
    @topic = create_topic :forum => @forum, :user => @user
    result = Topic.find_topics_for_forum(@forum).first
    result.last_active_user_id.should == @user.id.to_s
    result.last_active_user_display_name.should == @user.display_name
  end

  it 'should show the correct "last post" for topics with a reply' do
    @topic = create_topic :forum => @forum, :user => @user
    comment = create_comment :commentable => @topic, :user => @replier
    result = Topic.find_topics_for_forum(@forum).first
    result.last_active_user_id.should == @replier.id.to_s
    result.last_active_user_display_name.should == @replier.display_name

    # now delete
    comment.destroy
    result = Topic.find_topics_for_forum(@forum).first
    result.last_active_user_id.should == @user.id.to_s
    result.last_active_user_display_name.should == @user.display_name
  end

  it 'should show the correct "last post" for topics with an anonymous reply' do
    @topic = create_topic :forum => @forum, :user => @user
    comment = create_comment :commentable => @topic, :user => nil
    result = Topic.find_topics_for_forum(@forum).first
    result.last_active_user_id.should == nil
    result.last_active_user_display_name.should == nil

    # now delete
    comment.destroy
    result = Topic.find_topics_for_forum(@forum).first
    result.last_active_user_id.should == @user.id.to_s
    result.last_active_user_display_name.should == @user.display_name
  end

  it 'should show the correct "last post" for anonymous topics with no replies' do
    @topic = create_topic :forum => @forum, :user => nil
    result = Topic.find_topics_for_forum(@forum).first
    result.last_active_user_id.should == nil
    result.last_active_user_display_name.should == nil
  end

  it 'should show the correct "last post" for anonymous topics with a reply' do
    @topic = create_topic :forum => @forum, :user => nil
    comment = create_comment :commentable => @topic, :user => @replier
    result = Topic.find_topics_for_forum(@forum).first
    result.last_active_user_id.should == @replier.id.to_s
    result.last_active_user_display_name.should == @replier.display_name

    # now delete
    comment.destroy
    result = Topic.find_topics_for_forum(@forum).first
    result.last_active_user_id.should == nil
    result.last_active_user_display_name.should == nil
  end

  it 'should show the correct "last post" for anonymous topics with an anonymous reply' do
    @topic = create_topic :forum => @forum, :user => nil
    comment = create_comment :commentable => @topic, :user => nil
    result = Topic.find_topics_for_forum(@forum).first
    result.last_active_user_id.should == nil
    result.last_active_user_display_name.should == nil

    # now delete
    comment.destroy
    result = Topic.find_topics_for_forum(@forum).first
    result.last_active_user_id.should == nil
    result.last_active_user_display_name.should == nil
  end
end
