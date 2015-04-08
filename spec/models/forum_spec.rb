require 'spec_helper'

describe Forum, 'creation' do
  it 'should default to being public' do
    expect(Forum.make!.public).to eq(true)
  end

  it 'should auto-populate the "position" attribute upon creation' do
    expect(Forum.make!(position: nil).position).not_to be_nil
  end

  it 'should by default appear at the end of the list' do
    first   = Forum.make!
    second  = Forum.make!
    expect(second.position).to be > first.position
  end
end

describe Forum, 'topics association' do
  before do
    @forum = Forum.make!
  end

  def add_topic
    @forum.topics.create title: Sham.random, body: Sham.random
  end

  it 'should have many topics' do
    10.times { add_topic }
    expect(@forum.topics.length).to eq(10)
  end

  it 'should order topics in descending order by update date' do
    10.times do
      topic = add_topic
      Topic.where(id: topic).update_all(['updated_at = ?', topic.id.days.from_now])
    end
    expect(@forum.topics.pluck(:id)).to eq(Topic.order('updated_at DESC').pluck(:id))
  end

  it 'should destroy dependent topics when destroying' do
    10.times { add_topic }
    expect { @forum.destroy }.to change(Topic, :count).by(-10)
  end
end

# :name, :description
describe Forum, 'accessible attributes' do
  it 'should allow mass-assignment of the name' do
    expect(Forum.make).to allow_mass_assignment_of(name: Sham.random)
  end

  it 'should allow mass-assignment of the description' do
    expect(Forum.make).to allow_mass_assignment_of(description: Sham.random)
  end

  it 'should allow mass-assignment of the permalink' do
    expect(Forum.make).to allow_mass_assignment_of(permalink: Sham.random)
  end

  it 'allows mass-assignment of the position' do
    expect(Forum.make).to allow_mass_assignment_of(position: 10)
  end

  it 'allows mass-assignment of public' do
    expect(Forum.make(public: true)).to allow_mass_assignment_of(public: false)
  end
end

describe Forum, 'validating the name' do
  it 'should require it to be present' do
     expect(Forum.make(name: nil)).to fail_validation_for(:name)
  end

  it 'should allow letters and spaces' do
    words = Array.new(10).collect {|i| Sham.random }
    expect(Forum.make(name: words.join(' '))).not_to fail_validation_for(:name)
  end

  it 'should allow numbers' do
    name = "#{Sham.random}2"
    expect(Forum.make(name: name)).not_to fail_validation_for(:name)
  end

  it 'should allow hyphens' do
    name ="#{Sham.random}-#{Sham.random}"
    expect(Forum.make(name: name)).not_to fail_validation_for(:name)
  end

  it 'should disallow other punctuation' do
    expect(Forum.make(name: 'foo.bar')).to fail_validation_for(:name)
  end

  it 'should require it to be unique' do
    name = 'foo'
    Forum.make! name: name
    expect(Forum.make(name: name)).to fail_validation_for(:name)
  end
end

describe Forum, 'validating the permalink' do
  it 'should require it to be unique' do
    permalink = Sham.random
    expect(Forum.make!(permalink: permalink)).to be_valid
    expect(Forum.make(permalink: permalink)).to fail_validation_for(:permalink)
  end

  it 'should allow letters, numbers and hyphens' do
    forum = Forum.make(permalink: 'foo-bar-2')
    expect(forum).not_to fail_validation_for(:permalink)
  end

  it 'should disallow spaces' do
    expect(Forum.make(permalink: 'foo bar')).to fail_validation_for(:permalink)
  end

  it 'should disallow other punctuation' do
    expect(Forum.make(permalink: 'foo.bar')).to fail_validation_for(:permalink)
  end
end

describe Forum, 'autogeneration of permalink' do
  it 'should generate it based on name if not present' do
    name = Sham.random
    forum = Forum.make(name: name, permalink: nil)
    expect(forum).not_to fail_validation_for(:permalink)
    expect(forum.permalink).to eq(name.downcase)
  end

  it 'should downcase' do
    name = 'FooBar'
    forum = Forum.make(name: name, permalink: nil)
    expect(forum).not_to fail_validation_for(:permalink)
    expect(forum.permalink).to eq('foobar')
  end

  it 'should convert spaces into hyphens' do
    name = 'hello world'
    forum = Forum.make(name: name, permalink: nil)
    expect(forum).not_to fail_validation_for(:permalink)
    expect(forum.permalink).to eq('hello-world')
  end

  it 'should allow numbers' do
    name = 'area 51'
    forum = Forum.make(name: name, permalink: nil)
    expect(forum).not_to fail_validation_for(:permalink)
    expect(forum.permalink).to eq('area-51')
  end
end

describe Forum do
  describe '#name' do
    it 'defaults to nil' do
      expect(Forum.new.name).to be_nil
    end
  end

  describe '#description' do
    it 'defaults to nil' do
      expect(Forum.new.description).to be_nil
    end
  end

  describe '#topics_count' do
    it 'defaults to zero' do
      expect(Forum.new.topics_count).to be_zero
    end
  end

  describe '#created_at' do
    it 'defaults to nil' do
      expect(Forum.new.created_at).to be_nil
    end
  end

  describe '#updated_at' do
    it 'defaults to nil' do
      expect(Forum.new.updated_at).to be_nil
    end
  end

  describe '#position' do
    it 'defaults to nil' do
      expect(Forum.new.position).to be_nil
    end
  end

  describe '#public' do
    it 'defaults to true' do
      expect(Forum.new.public).to eq(true)
    end
  end

  describe '#permalink' do
    it 'defaults to nil' do
      expect(Forum.new.permalink).to be_nil
    end
  end

  describe '#find_with_param! method' do
    before do
      @name   = 'foo bar'
      @forum  = Forum.make! name: @name
    end

    it 'finds by permalink' do
      mock(Forum).find_by_permalink('foo bar') { @forum }
      Forum.find_with_param! @name
    end

    it 'should handle hyphens in the name' do
      expect(Forum.find_with_param!('foo-bar')).to eq(@forum)
    end

    it 'should by case agnostic' do
      expect(Forum.find_with_param!('FoO-baR')).to eq(@forum)
    end

    it 'should complain if not found' do
      expect { Forum.find_with_param!('non-existent') }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'works with the `published` scope (public forum)' do
      expect(Forum.published.find_with_param!('foo-bar')).to eq(@forum)
    end

    it 'works without the `publishd` scope (private forum)' do
      private_forum = Forum.make! name: 'baz', public: false
      expect(Forum.find_with_param!('baz')).to eq(private_forum)
      expect { Forum.published.find_with_param!('baz') }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#to_param' do
    it 'uses the permalink as the param' do
      permalink = Sham.random.downcase
      expect(Forum.make(permalink: permalink).to_param).to eq(permalink)
    end

    context 'new record' do
      it 'returns nil' do
        expect(Forum.new.to_param).to be_nil
      end
    end

    context 'dirty record' do
      it 'returns the old permalink' do
        forum = Forum.make! permalink: 'foo'
        forum.permalink = 'bar'
        expect(forum.to_param).to eq('foo')
      end
    end
  end
end

describe Forum, 'find_all method' do
  before do
    @forum = Forum.make!
  end

  def add_topic
    Topic.make! forum: @forum
  end

  it 'should find forums with topics' do
    add_topic
    expect(Forum.find_all.size).to eq(1)
  end

  it 'should find forums with no topics' do
    expect(Forum.find_all.size).to eq(1)
  end

  it 'should select the forum id' do
    expect(Forum.find_all.first.id).to eq(@forum.id)
  end

  it 'should select the forum name' do
    expect(Forum.find_all.first.name).to eq(@forum.name)
  end

  it 'should select the forum permalink' do
    expect(Forum.find_all.first.permalink).to eq(@forum.permalink)
  end

  it 'should select the forum description' do
    expect(Forum.find_all.first.description).to eq(@forum.description)
  end

  it 'should select the topics cont' do
    expect(Forum.find_all.first.topics_count).to eq(@forum.topics_count)
  end

  it 'should select the "last active topic date"' do
    topic1 = add_topic
    topic2 = add_topic
    topic3 = add_topic
    timestamp = 2.days.from_now
    Topic.where(id: topic2).update_all(['updated_at = ?', timestamp])

    # we lose some precision here, so can't use an equality comparison
    expect((Forum.find_all.first.last_active_at - timestamp).abs).to be <= 1.second
  end

  it 'should return nil for missing "last active topic date"' do
    expect(Forum.find_all.first.last_active_at).to be_nil
  end

  it 'should select the "last active topic id"' do
    topic1 = add_topic
    topic2 = add_topic
    topic3 = add_topic
    Topic.where(id: topic2).update_all(['updated_at = ?', 2.days.from_now])
    expect(Forum.find_all.first.last_topic_id).to eq(topic2.id)
  end

  it 'should return nil for missing "last active topic id"' do
    expect(Forum.find_all.first.last_topic_id).to be_nil
  end

  it 'should order results by the "position" attribute' do
    @forum.update_attribute :position, 1
    forum1 = Forum.make! position: 15
    forum2 = Forum.make! position: 5
    forum3 = Forum.make! position: 10
    expect(Forum.find_all.collect(&:id)).to eq([@forum, forum2, forum3, forum1].collect(&:id))
  end

  it 'should find only public forums' do
    start = Forum.find_all.length
    @forum.update_attribute(:public, false)
    finish = Forum.find_all.length
    expect(finish - start).to eq(-1)
  end

  # was a bug
  it 'should not count a topic awaiting moderation as a "last active" topic' do
    topic = add_topic
    topic.awaiting_moderation = true
    topic.save
    expect(Forum.find_all.first.last_topic_id).to be_nil
  end

  it 'should not allow a topic awaiting moderation to influence the "updated at" field' do
    topic = add_topic
    topic.awaiting_moderation = true
    topic.save
    expect(Forum.find_all.first.last_active_at).to be_nil
  end

  it 'should not count a private topic as a "last active" topic' do
    topic = add_topic
    topic.public = false
    topic.save
    expect(Forum.find_all.first.last_topic_id).to be_nil
  end

  it 'should not allow a private topic to influence the "updated at" field' do
    topic = add_topic
    topic.public = false
    topic.save
    expect(Forum.find_all.first.last_active_at).to be_nil
  end
end

# "last post" info wrong for anonymous comments?
describe Forum, 'http://rails.wincent.com/issues/671' do
  before do
    @forum    = Forum.make!
    @user     = User.make!
    @replier  = User.make!
  end

  # note with all these specs we test after deletion as well as after creation
  it 'should show the correct "last post" for topics with no replies' do
    @topic = Topic.make! forum: @forum, user: @user
    result = Topic.find_topics_for_forum(@forum).first
    expect(result.last_active_user_id).to eq(@user.id)
    expect(result.last_active_user_display_name).to eq(@user.display_name)
  end

  it 'should show the correct "last post" for topics with a reply' do
    @topic = Topic.make! forum: @forum, user: @user
    comment = Comment.make! commentable: @topic, user: @replier
    result = Topic.find_topics_for_forum(@forum).first
    expect(result.last_active_user_id).to eq(@replier.id)
    expect(result.last_active_user_display_name).to eq(@replier.display_name)

    # now delete
    comment.destroy
    result = Topic.find_topics_for_forum(@forum).first
    expect(result.last_active_user_id).to eq(@user.id)
    expect(result.last_active_user_display_name).to eq(@user.display_name)
  end

  it 'should show the correct "last post" for topics with an anonymous reply' do
    @topic = Topic.make! forum: @forum, user: @user
    comment = Comment.make! commentable: @topic, user: nil
    result = Topic.find_topics_for_forum(@forum).first
    expect(result.last_active_user_id).to eq(nil)
    expect(result.last_active_user_display_name).to eq(nil)

    # now delete
    comment.destroy
    result = Topic.find_topics_for_forum(@forum).first
    expect(result.last_active_user_id).to eq(@user.id)
    expect(result.last_active_user_display_name).to eq(@user.display_name)
  end

  it 'should show the correct "last post" for anonymous topics with no replies' do
    @topic = Topic.make! forum: @forum, user: nil
    result = Topic.find_topics_for_forum(@forum).first
    expect(result.last_active_user_id).to eq(nil)
    expect(result.last_active_user_display_name).to eq(nil)
  end

  it 'should show the correct "last post" for anonymous topics with a reply' do
    @topic = Topic.make! forum: @forum, user: nil
    comment = Comment.make! commentable: @topic, user: @replier
    result = Topic.find_topics_for_forum(@forum).first
    expect(result.last_active_user_id).to eq(@replier.id)
    expect(result.last_active_user_display_name).to eq(@replier.display_name)

    # now delete
    comment.destroy
    result = Topic.find_topics_for_forum(@forum).first
    expect(result.last_active_user_id).to eq(nil)
    expect(result.last_active_user_display_name).to eq(nil)
  end

  it 'should show the correct "last post" for anonymous topics with an anonymous reply' do
    @topic = Topic.make! forum: @forum, user: nil
    comment = Comment.make! commentable: @topic, user: nil
    result = Topic.find_topics_for_forum(@forum).first
    expect(result.last_active_user_id).to eq(nil)
    expect(result.last_active_user_display_name).to eq(nil)

    # now delete
    comment.destroy
    result = Topic.find_topics_for_forum(@forum).first
    expect(result.last_active_user_id).to eq(nil)
    expect(result.last_active_user_display_name).to eq(nil)
  end
end
