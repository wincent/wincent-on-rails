require 'spec_helper'

describe Tweet do
  describe 'attributes' do
    describe '#body' do
      it 'defaults to nil' do
        Tweet.new.body.should be_nil
      end
    end

    describe '#created_at' do
      it 'defaults to nil' do
        Tweet.new.created_at.should be_nil
      end
    end

    describe '#updated_at' do
      it 'defaults to nil' do
        Tweet.new.updated_at.should be_nil
      end
    end

    describe '#accepts_comments' do
      it 'defaults to true' do
        Tweet.new.accepts_comments.should be_true
      end
    end

    describe '#comments_count' do
      it 'defaults to zero' do
        Tweet.new.comments_count.should be_zero
      end
    end

    describe '#last_commenter_id' do
      it 'defaults to nil' do
        Tweet.new.last_commenter_id.should be_nil
      end
    end

    describe '#last_comment_id' do
      it 'defaults to nil' do
        Tweet.new.last_comment_id.should be_nil
      end
    end

    describe '#last_commented_at' do
      it 'defaults to nil' do
        Tweet.new.last_commented_at.should be_nil
      end
    end
  end

  it 'should be valid' do
    Tweet.make.should be_valid
  end

  # like Twitter, but advisory rather than a strict limit
  it 'should have a recommended maximum length of 140 characters' do
    Tweet::RECOMMENDED_MAX_LENGTH.should == 140
  end

  it 'should default to accepting comments' do
    Tweet.make.accepts_comments.should == true
  end

  let(:commentable) { Tweet.make! }
  it_has_behavior 'commentable'
  it_has_behavior 'commentable (not updating timestamps for comment changes)'

  it_has_behavior 'taggable' do
    let(:model) { Tweet.make! }
    let(:new_model) { Tweet.make }
  end

  describe '.short_link_from_id' do
    subject { Tweet.short_link_from_id(id) }

    context 'with an id of 0' do
      let(:id) { 0 }
      it { should == '0' }
    end

    context 'with an id of 1' do
      let(:id) { 1 }
      it { should == '1' }
    end

    context 'with an id of 78 (about to wrap around)' do
      let(:id) { 78 }
      it { should == '-' }
    end

    context 'with an id of 79 (just wrapped around)' do
      let(:id) { 79 }
      it { should == '10' }
    end
  end

  describe '.id_from_short_link' do
    subject { Tweet.id_from_short_link(link) }

    context 'with a link of "-"' do
      let(:link) { '-' }
      it { should == 78 }
    end

    context 'with a link of "10"' do
      let(:link) { '10' }
      it { should == 79 }
    end

    it 'can round trip' do
      link = 'b@:-1Xy2'
      id = Tweet.id_from_short_link(link)
      Tweet.short_link_from_id(id).should == link
    end
  end

  describe '#shortlink' do
    context 'with a new record' do
      it 'explodes' do
        expect { Tweet.new.short_link }.to raise_error
      end
    end

    context 'with an existing record' do
      let(:tweet) { Tweet.make! }

      it 'delegates to the .short_link_from_id class method' do
        mock(Tweet).short_link_from_id(tweet.id)
        tweet.short_link
      end
    end
  end
end

describe Tweet, 'comments association' do
  it 'should respond to the comments message' do
    Tweet.make!.comments.should == []
  end
end

describe Tweet, 'validation' do
  it 'should require the body to be present' do
    Tweet.new(:body => '').should fail_validation_for(:body)
  end
end

# :body
describe Tweet, 'accessible attributes' do
  it 'should allow mass-assignment to the body' do
    Tweet.make.should allow_mass_assignment_of(:body => 'foo')
  end
end

describe Tweet, 'find_recent (class) method (interaction-based approach)' do
  it 'should find no more than 20 tweets' do
    mock(Tweet).find :all, hash_including(:limit => 20)
    Tweet.find_recent
  end

  it 'should sort tweets in reverse creation order' do
    mock(Tweet).find :all, hash_including(:order => 'created_at DESC')
    Tweet.find_recent
  end

  it 'should use custom offset if supplied' do
    mock(Tweet).find :all, hash_including(:offset => 35)
    Tweet.find_recent :offset => 35
  end

  it 'should use custom limit if supplied' do
    mock(Tweet).find :all, hash_including(:limit => 100)
    Tweet.find_recent :limit => 100
  end
end

describe Tweet, 'find_recent (class) method (state-based approach)' do
  def old_tweet days_count
    past = days_count.days.ago
    tweet = Tweet.make!
    Tweet.update_all ['created_at = ?, updated_at = ?', past, past], ['id = ?', tweet.id]
    tweet
  end

  it 'should find no more than 20 tweets' do
    25.times { Tweet.make! }
    Tweet.find_recent.length.should <= 20
  end

  it 'should sort tweets in reverse creation order' do
    old = old_tweet(3)
    new = Tweet.make!
    Tweet.find_recent.should == [new, old]
  end

  it 'should use offset from paginator if supplied' do
    first = old_tweet(10)
    second = old_tweet(8)
    third = old_tweet(6)
    fourth = Tweet.make!
    paginator = RestfulPaginator.new({ :page => 2 }, 4, 'foo', 2)
    Tweet.find_recent(:offset => paginator.offset,
      :limit => paginator.limit).should == [second, first]
  end

  it 'should use limit from paginator if supplied' do
    20.times { Tweet.make! }
    paginator = RestfulPaginator.new({}, 20, 'foo', 10)
    Tweet.find_recent(:offset => paginator.offset,
      :limit => paginator.limit).length.should == 10
  end
end

describe Tweet, 'rendered_length method' do
  before do
    @tweet = Tweet.new
  end

  it 'should return a rendered length of 0 if body is empty' do
    @tweet.rendered_length.should == 0
  end

  it 'should return rendered length of plain text' do
    @tweet.body = 'hello'
    @tweet.rendered_length.should == 5
  end

  it 'should not include HTML tags in length' do
    @tweet.body = '[[hello]]'
    @tweet.rendered_length.should == 5
    @tweet.body = '<em>hello</em>'
    @tweet.rendered_length.should == 5
    @tweet.body = '[http://example.com/ hello]'
    @tweet.rendered_length.should == 5
    @tweet.body = "'''hello'''"
    @tweet.rendered_length.should == 5
  end
end

describe Tweet, 'overlength? method' do
  before do
    @tweet = Tweet.new
  end

  it 'should respond to the "overlength?" message' do
    @tweet.should respond_to(:overlength?)
  end

  it 'should return false for new tweets' do
    @tweet.should_not be_overlength
  end

  it 'should return false for tweets of 140 characters or less' do
    @tweet.body = 'hello'
    @tweet.should_not be_overlength
    @tweet.body = 'x' * 140
    @tweet.should_not be_overlength
  end

  it 'should return true for tweets of over 140 characters' do
    @tweet.body = 'x' * 141
    @tweet.should be_overlength
  end

  it 'should not include HTML tags in the tag count' do
    @tweet.body = '[[' + ('x' * 140) + ']]'
    @tweet.should_not be_overlength
  end
end
