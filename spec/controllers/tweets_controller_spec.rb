require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.dirname(__FILE__) + '/application_controller_spec'
require 'hpricot'

describe TweetsController do
  it_should_behave_like 'ApplicationController'
end

# For an explanation of why I test this method in two ways,
# see: https://wincent.com/blog/testing-inquietitude
describe TweetsController, 'GET /twitter ("internals" approach)' do
  before do
    @params = { 'action' => 'index', 'controller' => 'tweets', 'protocol' => 'https' }
  end

  def do_get
    get :index, :protocol => 'https'
  end

  it 'should be successful' do
    do_get
    response.should be_success
  end

  it 'should render the "tweets/index.html.haml" template' do
    do_get
    response.should render_template('tweets/index.html.haml')
  end

  it 'should use the restful paginator' do
    paginator = RestfulPaginator.new(@params, Tweet.count, tweets_url, 20)
    RestfulPaginator.stub!(:new).with(@params, Tweet.count, tweets_url, 20).and_return(paginator)
    do_get
    assigns[:paginator].should == paginator
  end

  it 'should correctly configure the restful paginator' do
    RestfulPaginator.should_receive(:new).with(@params, Tweet.count, tweets_url, 20)
    do_get
  end

  it 'should find recent tweets' do
    paginator = RestfulPaginator.new(@params, Tweet.count, tweets_url, 20)
    RestfulPaginator.stub!(:new).with(@params, Tweet.count, tweets_url, 20).and_return(paginator)
    Tweet.should_receive(:find_recent).with(paginator)
    do_get
  end

  it 'should assign the recent tweets to the @tweets instance variable' do
    Tweet.stub!(:find_recent).and_return([:recent])
    do_get
    assigns[:tweets].should == [:recent]
  end
end

# For an explanation of why I test this method in two ways,
# see: https://wincent.com/blog/testing-inquietitude
describe TweetsController, 'GET /twitter ("black box" approach)' do
  def do_get
    get :index, :protocol => 'https'
  end

  it 'should be successful' do
    do_get
    response.should be_success
  end

  it 'should render the "tweets/index.html.haml" template' do
    do_get
    response.should render_template('tweets/index.html.haml')
  end

  it 'should function when there are no tweets in the database' do
    do_get
    assigns[:tweets].should == []
  end

  it 'should function when there is one tweet in the database' do
    tweet = create_tweet
    do_get
    assigns[:tweets].should == [tweet]
  end

  it 'should fetch no more than 20 tweets at a time' do
    25.times { create_tweet }
    do_get
    assigns[:tweets].length.should == 20
  end

  it 'should fetch tweets in reverse creation order' do
    past = 3.days.ago
    old = create_tweet
    Tweet.update_all ['created_at = ?, updated_at = ?', past, past], ['id = ?', old.id]
    new = create_tweet
    do_get
    assigns[:tweets].should == [new, old]
  end

  it 'should assign to the @paginator instance variable' do
    do_get
    assigns[:paginator].should be_kind_of(RestfulPaginator)
  end

  # this may look like we're overly concerned with internals here
  # but we simply can't test that the paginator is properly set up anywhere else
  # we care about the external behaviour of the paginator
  # is the limit right? is the offset right? is the count right? are the URLs right?
  # we don't test the params because that is an implementation detail for this controller
  # (there are no "interesting" params, like sorting or whatever)
  it 'should inform the paginator of the total number of records' do
    do_get
    assigns[:paginator].count.should == Tweet.count
  end

  it 'should tell the paginator to use the /twitter URL for link generation' do
    do_get
    assigns[:paginator].path_or_url.should == tweets_url
  end

  it 'should configure the paginator to paginate in groups of 20' do
    do_get
    assigns[:paginator].limit.should == 20
  end

  it 'should show the first page by default' do
    do_get
    assigns[:paginator].offset.should == 0
  end

  it 'should page-cache the output' do
    controller.should_receive(:cache_page)
    do_get
  end
end

describe TweetsController, 'GET /twitter.atom' do
  integrate_views # so that we can test layouts as well

  before do
    10.times { create_tweet }
  end

  def do_get
    get :index, :format => 'atom', :protocol => 'https'
  end

  it 'should be successful' do
    do_get
    response.should be_success
  end

  it 'should render the "tweets/index.atom.builder" template' do
    do_get
    response.should render_template('tweets/index.atom.builder')
  end

  it 'should find recent tweets' do
    Tweet.should_receive(:find_recent).and_return([])
    do_get
  end

  it 'should assign to the @tweets instance variable' do
    do_get
    assigns[:tweets].should be_kind_of(Array)
    assigns[:tweets].length.should == 10
  end

  it 'should page-cache the output' do
    controller.should_receive(:cache_page)
    do_get
  end

  it 'should produce valid atom when there are no tweets' do
    pending unless can_validate_feeds?
    Tweet.destroy_all
    do_get
    response.body.should be_valid_atom
  end

  it 'should produce valid atom when there are multiple tweets' do
    pending unless can_validate_feeds?
    do_get
    response.body.should be_valid_atom
  end

  # Rails 2.3.0 RC1 BUG: http://rails.lighthouseapp.com/projects/8994/tickets/2043
  it 'should produce entry links to HTML-formatted records' do
    do_get
    doc = Hpricot.XML(response.body)
    (doc/:entry).collect do |entry|
      (entry/:link).first[:href].each do |href|
        # make sure links are /twitter/1234, not /twitter/1234.atom
        href.should =~ %r{/twitter/\d+\z}
      end
    end
  end
end

describe TweetsController, 'GET /twitter/new' do
  def do_get admin = true
    login_as_admin if admin == true
    get :new, :protocol => 'https'
  end

  it 'should redirect for non-admins' do
    do_get :not_as_admin
    response.should redirect_to(login_url)
  end

  it 'should be successful' do
    do_get
    response.should be_success
  end

  it 'should assign to the @tweet instance variable' do
    do_get
    assigns[:tweet].should be_kind_of(Tweet)
  end

  it 'should render the "tweets/new.html.haml" template' do
    do_get
    response.should render_template('tweets/new.html.haml')
  end
end

describe TweetsController, 'POST /twitter' do
  def do_post params = {}, admin = true
    login_as_admin if admin == true
    post :create, params.merge({ :protocol => 'https' })
  end

  def do_successful_post
    Tweet.stub!(:new).and_return(@tweet)
    do_post
  end

  def do_failed_post
    Tweet.stub!(:new).and_return(@tweet)
    @tweet.stub!(:save).and_return(false)
    do_post
  end

  before do
    @params   = { :tweet => { 'body' => 'foo bar baz' } }
    @tweet    = Tweet.new @params[:tweet]
  end

  it 'should redirect for non-admins' do
    do_post({}, :not_as_admin)
    response.should redirect_to(login_url)
  end

  it 'should create a new tweet record' do
    Tweet.should_receive(:new).with(@params[:tweet]).and_return(@tweet)
    do_post @params
  end

  it 'should assign to the @tweet instance variable' do
    Tweet.stub!(:new).and_return(@tweet)
    do_post
    assigns[:tweet].should == @tweet
  end

  it 'should save the new record' do
    Tweet.stub!(:new).and_return(@tweet)
    @tweet.should_receive(:save)
    do_post
  end

  it 'should not flash a notice on success' do
    # flashes would pollute the page cache
    do_successful_post
    flash[:notice].should be_nil
  end

  it 'should redirect to the tweet "show" page on success' do
    do_successful_post
    response.should redirect_to(tweet_url(@tweet))
  end

  it 'should flash an error on failure' do
    do_failed_post
    flash[:error].should =~ /Failed/
  end

  it 'should render the "tweets/new.html.haml" template on failure' do
    do_failed_post
    response.should render_template('tweets/new.html.haml')
  end

  it 'should trigger the cache sweeper' do
    TweetSweeper.instance.should_receive(:after_save).with(@tweet)
    Tweet.stub!(:new).and_return(@tweet)
    do_post
  end
end

describe TweetsController, 'POST /twitter.js (AJAX preview)' do
  def do_post params = {}, admin = true
    login_as_admin if admin == true
    post :create, params.merge({ :protocol => 'https', :format => 'js' })
  end

  it 'should return an error for non-admins' do
    do_post({}, :not_as_admin)
    response.should_not be_success
    response.status.should == '403 Forbidden'
    response.body.should be_blank
  end

  it 'should assign to the @tweet instance variable' do
    Tweet.should_receive(:new).with({ :body => 'foo' })
    do_post({ :body => 'foo' })
  end

  it 'should render the "tweets/_preview.html.haml" template' do
    do_post
    response.should render_template('tweets/_preview.html.haml')
  end

  it 'should not trigger the cache sweeper' do
    TweetSweeper.instance.should_not_receive(:after_save)
    do_post
  end
end

describe TweetsController, 'GET /twitter/:id' do
  def do_get tweet
    get :show, :id => tweet.id, :protocol => 'https'
  end

  before do
    @tweet = create_tweet
  end

  it 'should be successful' do
    do_get @tweet
    response.should be_success
  end

  it 'should assign to the @tweet instance variable' do
    do_get @tweet
    assigns[:tweet].should == @tweet
  end

  it 'should render the "tweets/show.html.haml" template' do
    do_get @tweet
    response.should render_template('tweets/show.html.haml')
  end

  it 'should redirect to the root URL if not found' do
    # can't redirect to tweets index
    # (the flash would pollute page cache)
    tweet = new_tweet
    tweet.id = 1_342_103
    do_get tweet
    response.should redirect_to(root_url)
  end

  it 'should page-cache the output' do
    controller.should_receive(:cache_page)
    do_get @tweet
  end
end

describe TweetsController, 'GET /twitter/:id/edit' do
  def do_get tweet, admin = true
    login_as_admin if admin == true
    get :edit, :id => tweet.id, :protocol => 'https'
  end

  before do
    @tweet = create_tweet
  end

  it 'should redirect for non-admins' do
    do_get @tweet, :not_as_admin
    response.should redirect_to(login_url)
  end

  it 'should be successful' do
    do_get @tweet
    response.should be_success
  end

  it 'should assign to the @tweet instance variable' do
    do_get @tweet
    assigns[:tweet].should == @tweet
  end

  it 'should render the "tweets/edit.html.haml" template' do
    do_get @tweet
    response.should render_template('tweets/edit.html.haml')
  end

  it 'should redirect to the root URL if not found' do
    # can't redirect to tweets index
    # (the flash would pollute page cache)
    tweet = new_tweet
    tweet.id = 1_342_103
    do_get tweet
    response.should redirect_to(root_url)
  end
end

describe TweetsController, 'PUT /twitter/:id' do
  def do_put tweet, admin = true, params = {}
    login_as_admin if admin == true
    put :update, params.merge({:id => tweet.id, :protocol => 'https'})
  end

  def do_successful_update
    Tweet.stub!(:find).and_return(@tweet)
    @tweet.stub!(:update_attributes).and_return(true)
    do_put @tweet
  end

  def do_failed_update
    Tweet.stub!(:find).and_return(@tweet)
    @tweet.stub!(:update_attributes).and_return(false)
    do_put @tweet
  end

  before do
    @tweet = create_tweet
  end

  it 'should redirect for non-admins' do
    do_put @tweet, :not_as_admin
    response.should redirect_to(login_url)
  end

  it 'should be successful' do
    do_put @tweet
    response.should be_success
  end

  it 'should assign to the @tweet instance variable' do
    do_put @tweet
    assigns[:tweet].should == @tweet
  end

  it 'should update the tweet record' do
    params = { :tweet => { 'body' => 'foo' } }
    Tweet.stub!(:find).and_return(@tweet)
    @tweet.should_receive(:update_attributes).with(params[:tweet])
    do_put @tweet, true, params
  end

  it 'should not flash a notice on success' do
    # flashes would pollute the page cache
    do_successful_update
    flash[:notice].should be_nil
  end

  it 'should render the "tweets/show.html.haml" template on success' do
    do_successful_update
    response.should render_template('tweets/show.html.haml')
  end

  it 'should flash an error on failure' do
    do_failed_update
    flash[:error].should =~ /failed/
  end

  it 'should render the "tweets/edit.html.haml" template on failure' do
    do_failed_update
    response.should render_template('tweets/edit.html.haml')
  end

  it 'should trigger the cache sweeper' do
    TweetSweeper.instance.should_receive(:after_save).with(@tweet)
    do_put @tweet
  end
end

describe TweetsController, 'DELETE /twitter/:id' do
  def do_delete tweet, admin = true
    login_as_admin if admin == true
    delete :destroy, :id => tweet.id, :protocol => 'https'
  end

  before do
    @tweet = create_tweet
  end

  it 'should redirect for non-admins' do
    do_delete @tweet, :not_as_admin
    response.should redirect_to(login_url)
  end

  it 'should destroy the tweet' do
    do_delete @tweet
    lambda { Tweet.find(@tweet.id) }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it 'should redirect to the tweets index' do
    do_delete @tweet
    response.should redirect_to(tweets_url)
  end

  it 'should redirect to the root URL if not found' do
    # can't redirect to tweets index
    # (the flash would pollute page cache)
    tweet = new_tweet
    tweet.id = 1_342_103
    do_delete tweet
    response.should redirect_to(root_url)
  end

  it 'should trigger the cache sweeper' do
    TweetSweeper.instance.should_receive(:after_destroy).with(@tweet)
    do_delete @tweet
  end
end
