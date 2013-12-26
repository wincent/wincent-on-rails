require 'spec_helper'

describe TweetsController do
  it_should_behave_like 'ApplicationController subclass'

  describe '#index' do
    def do_get
      get :index
    end

    it 'succeeds' do
      do_get
      response.should be_success
    end

    it 'renders the #index template' do
      do_get
      response.should render_template('index')
    end

    it 'works when there are no tweets in the database' do
      do_get
      assigns[:tweets].should == []
    end

    it 'works when there is one tweet in the database' do
      tweet = Tweet.make!
      do_get
      assigns[:tweets].should == [tweet]
    end

    it 'fetchs no more than 20 tweets at a time' do
      25.times { Tweet.make! }
      do_get
      assigns[:tweets].length.should == 20
    end

    it 'fetches tweets in reverse creation order' do
      past = 3.days.ago
      old = Tweet.make!
      Tweet.where(id: old).update_all ['created_at = ?, updated_at = ?', past, past]
      new = Tweet.make!
      do_get
      assigns[:tweets].should == [new, old]
    end

    it 'assigns to the @paginator instance variable' do
      do_get
      assigns[:paginator].should be_kind_of(RestfulPaginator)
    end

    it 'informs the paginator of the total number of records' do
      do_get
      assigns[:paginator].count.should == Tweet.count
    end

    it 'tells the paginator to use the /twitter URL for link generation' do
      do_get
      assigns[:paginator].path_or_url.should == tweets_path
    end

    it 'configures the paginator to paginate in groups of 20' do
      do_get
      assigns[:paginator].limit.should == 20
    end

    it 'shows the first page by default' do
      do_get
      assigns[:paginator].offset.should == 0
    end
  end

  describe '#new' do
    def do_get admin = true
      log_in_as_admin if admin == true
      get :new
    end

    it 'should redirect for non-admins' do
      do_get :not_as_admin
      response.should redirect_to(login_path)
    end

    it 'should be successful' do
      do_get
      response.should be_success
    end

    it 'should assign to the @tweet instance variable' do
      do_get
      assigns[:tweet].should be_kind_of(Tweet)
    end

    it 'should render the #new template' do
      do_get
      response.should render_template('new')
    end
  end

  describe '#create' do
    def do_post params = {}, admin = true
      log_in_as_admin if admin == true
      post :create, params
    end

    def do_successful_post
      stub(Tweet).new { @tweet }
      do_post
    end

    def do_failed_post
      stub(Tweet).new { @tweet }
      stub(@tweet).save { false }
      do_post
    end

    before do
      @params   = { tweet: { 'body' => 'foo bar baz' } }
      @tweet    = Tweet.new @params[:tweet]
    end

    it 'should redirect for non-admins' do
      do_post({}, :not_as_admin)
      response.should redirect_to(login_path)
    end

    it 'should create a new tweet record' do
      mock(Tweet).new(@params[:tweet]) { @tweet }
      do_post @params
    end

    it 'should assign to the @tweet instance variable' do
      stub(Tweet).new { @tweet }
      do_post
      assigns[:tweet].should == @tweet
    end

    it 'should save the new record' do
      stub(Tweet).new { @tweet }
      mock(@tweet).save
      do_post
    end

    it 'shows a flash' do
      do_successful_post
      flash[:notice].should =~ /successfully created new tweet/i
    end

    it 'should redirect to the tweet "show" page on success' do
      do_successful_post
      response.should redirect_to(tweet_url(@tweet))
    end

    it 'should flash an error on failure' do
      do_failed_post
      flash[:error].should =~ /Failed/
    end

    it 'should render the #new template on failure' do
      do_failed_post
      response.should render_template('new')
    end
  end

  describe '#create (via AJAX)' do
    def do_post params = {}, admin = true
      request.env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest'
      log_in_as_admin if admin == true
      post :create, params.merge(format: 'js')
    end

    it 'should return an error for non-admins' do
      do_post({}, :not_as_admin)
      response.should_not be_success
      response.status.should == 403
      response.body.should =~ /Forbidden/
    end

    it 'should assign to the @tweet instance variable' do
      mock(Tweet).new(body: 'foo')
      do_post(body: 'foo')
    end

    it 'should render the "tweets/_preview" template' do
      do_post
      response.should render_template('tweets/_preview')
    end
  end

  describe '#show' do
    def do_get tweet
      get :show, id: tweet.id
    end

    before do
      @tweet = Tweet.make!
    end

    it 'should be successful' do
      do_get @tweet
      response.should be_success
    end

    it 'should assign to the @tweet instance variable' do
      do_get @tweet
      assigns[:tweet].should == @tweet
    end

    it 'should render the #show template' do
      do_get @tweet
      response.should render_template('show')
    end

    it 'should redirect to the tweets index if not found' do
      tweet = Tweet.make
      tweet.id = 1_342_103
      do_get tweet
      response.should redirect_to(tweets_path)
    end
  end

  describe '#edit' do
    def do_get tweet, admin = true
      log_in_as_admin if admin == true
      get :edit, id: tweet.id
    end

    before do
      @tweet = Tweet.make!
    end

    it 'should redirect for non-admins' do
      do_get @tweet, :not_as_admin
      response.should redirect_to(login_path)
    end

    it 'should be successful' do
      do_get @tweet
      response.should be_success
    end

    it 'should assign to the @tweet instance variable' do
      do_get @tweet
      assigns[:tweet].should == @tweet
    end

    it 'should render the #edit template' do
      do_get @tweet
      response.should render_template('edit')
    end

    it 'should redirect to the tweets index if not found' do
      tweet = Tweet.make
      tweet.id = 1_342_103
      do_get tweet
      response.should redirect_to(tweets_path)
    end
  end

  describe '#update' do
    def do_put tweet, admin = true, params = {}
      log_in_as_admin if admin == true
      put :update, params.merge(id: tweet.id)
    end

    def do_successful_update
      stub(Tweet).find { @tweet }
      stub(@tweet).update_attributes { true }
      do_put @tweet
    end

    def do_failed_update
      stub(Tweet).find { @tweet }
      stub(@tweet).update_attributes { false }
      do_put @tweet
    end

    before do
      @tweet = Tweet.make!
    end

    it 'should redirect for non-admins' do
      do_put @tweet, :not_as_admin
      response.should redirect_to(login_path)
    end

    it 'should assign to the @tweet instance variable' do
      do_put @tweet
      assigns[:tweet].should == @tweet
    end

    it 'should update the tweet record' do
      params = { tweet: { 'body' => 'foo' } }
      stub(Tweet).find { @tweet }
      mock(@tweet).update_attributes(params[:tweet])
      do_put @tweet, true, params
    end

    it 'shows a flash' do
      do_successful_update
      flash[:notice].should =~ /successfully updated/i
    end

    it 'should redirect to the tweet "show" page on success' do
      do_successful_update
      response.should redirect_to(tweet_url(@tweet))
    end

    it 'should flash an error on failure' do
      do_failed_update
      flash[:error].should =~ /failed/
    end

    it 'should render the #edit template on failure' do
      do_failed_update
      response.should render_template('edit')
    end
  end

  describe '#destroy' do
    def do_delete tweet, admin = true
      log_in_as_admin if admin == true
      delete :destroy, id: tweet.id
    end

    before do
      @tweet = Tweet.make!
    end

    it 'should redirect for non-admins' do
      do_delete @tweet, :not_as_admin
      response.should redirect_to(login_path)
    end

    it 'should destroy the tweet' do
      do_delete @tweet
      expect { Tweet.find(@tweet.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'should redirect to the tweets index' do
      do_delete @tweet
      response.should redirect_to(tweets_path)
    end

    it 'should redirect to the tweets index if not found' do
      tweet = Tweet.make
      tweet.id = 1_342_103
      do_delete tweet
      response.should redirect_to(tweets_path)
    end
  end
end
