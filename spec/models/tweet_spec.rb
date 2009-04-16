require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tweet do
  it 'should be valid' do
    new_tweet.should be_valid
  end

  # like Twitter, but advisory rather than a strict limit
  it 'should have a recommended maximum length of 140 characters' do
    Tweet::RECOMMENDED_MAX_LENGTH.should == 140
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
    new_tweet.should allow_mass_assignment_of(:body => 'foo')
  end
end

# :created_at, :updated_at
describe Tweet, 'protected attributes' do
  it 'should deny mass-assignment to the created at attribute' do
    create_tweet.should_not allow_mass_assignment_of(:created_at => 5.months.ago)
  end

  it 'should deny mass-assignment to the update at attribute' do
    create_tweet.should_not allow_mass_assignment_of(:updated_at => 1.week.ago)
  end
end

describe Tweet, 'find_recent (class) method (interaction-based approach)' do
  it 'should find no more than 20 tweets' do
    Tweet.should_receive(:find).with(:all, hash_including(:limit => 20))
    Tweet.find_recent
  end

  it 'should sort tweets in reverse creation order' do
    Tweet.should_receive(:find).with(:all, hash_including(:order => 'created_at DESC'))
    Tweet.find_recent
  end

  it 'should use offset from paginator if supplied' do
    paginator = mock('paginator')
    paginator.should_receive(:offset).and_return(35)
    paginator.stub!(:limit).and_return(10)
    Tweet.should_receive(:find).with(:all, hash_including(:offset => 35))
    Tweet.find_recent paginator
  end

  it 'should use limit from paginator if supplied' do
    paginator = mock('paginator')
    paginator.should_receive(:limit).and_return(100)
    paginator.stub!(:offset).and_return(20)
    Tweet.should_receive(:find).with(:all, hash_including(:limit => 100))
    Tweet.find_recent paginator
  end
end

describe Tweet, 'find_recent (class) method (state-based approach)' do
  def old_tweet days_count
    past = days_count.days.ago
    tweet = create_tweet
    Tweet.update_all ['created_at = ?, updated_at = ?', past, past], ['id = ?', tweet.id]
    tweet
  end

  it 'should find no more than 20 tweets' do
    25.times { create_tweet }
    Tweet.find_recent.length.should <= 20
  end

  it 'should sort tweets in reverse creation order' do
    old = old_tweet(3)
    new = create_tweet
    Tweet.find_recent.should == [new, old]
  end

  it 'should use offset from paginator if supplied' do
    first = old_tweet(10)
    second = old_tweet(8)
    third = old_tweet(6)
    fourth = create_tweet
    paginator = RestfulPaginator.new({ :page => 2 }, 4, 'foo', 2)
    Tweet.find_recent(paginator).should == [second, first]
  end

  it 'should use limit from paginator if supplied' do
    20.times { create_tweet }
    paginator = RestfulPaginator.new({}, 20, 'foo', 10)
    Tweet.find_recent(paginator).length.should == 10
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
