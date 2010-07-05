require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe TweetsController do
  describe 'routing' do
    it { get('/twitter').should map('tweets#index') }
    it { get('/twitter/new').should map('tweets#new') }
    it { get('/twitter/123').should map('tweets#show', :id => '123') }
    it { get('/twitter/123/edit').should map('tweets#edit', :id => '123') }
    it { put('/twitter/123').should map('tweets#update', :id => '123') }
    it { delete('/twitter/123').should map('tweets#destroy', :id => '123') }
    it { post('/twitter').should map('tweets#create') }

    describe 'index pagination' do
      it { get('/twitter/page/2').should map('tweets#index', :page => '2') }

      it 'rejects non-numeric :page params' do
        get('/twitter/page/foo').should_not be_routable
      end
    end

    describe 'helpers' do
      before do
        @tweet = Tweet.stub :id => 123
      end

      describe 'tweets_path' do
        it { tweets_path.should == '/twitter' }
      end

      describe 'new_tweet_path' do
        it { new_tweet_path.should == '/twitter/new' }
      end

      describe 'tweet_path' do
        it { tweet_path(@tweet).should == '/twitter/123' }
      end

      describe 'edit_tweet_path' do
        it { edit_tweet_path(@tweet).should == '/twitter/123/edit' }
      end

      describe 'edit_tweet_path' do
        it { edit_tweet_path(@tweet).should == '/twitter/123/edit' }
      end
    end
  end
end
