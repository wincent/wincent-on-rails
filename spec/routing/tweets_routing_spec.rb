require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe TweetsController do
  describe 'routing' do
    specify { get('/twitter').should map('tweets#index') }
    specify { get('/twitter/new').should map('tweets#new') }
    specify { get('/twitter/123').should map('tweets#show', :id => '123') }
    specify { get('/twitter/123/edit').should map('tweets#edit', :id => '123') }
    specify { put('/twitter/123').should map('tweets#update', :id => '123') }
    specify { delete('/twitter/123').should map('tweets#destroy', :id => '123') }
    specify { post('/twitter').should map('tweets#create') }

    describe 'index pagination' do
      specify { get('/twitter/page/2').should map('tweets#index', :page => '2') }

      it 'rejects non-numeric :page params' do
        get('/twitter/page/foo').should_not be_routable
      end
    end

    describe 'helpers' do
      before do
        @tweet = Tweet.stub :id => 123
      end

      describe 'tweets_path' do
        specify { tweets_path.should == '/twitter' }
      end

      describe 'new_tweet_path' do
        specify { new_tweet_path.should == '/twitter/new' }
      end

      describe 'tweet_path' do
        specify { tweet_path(@tweet).should == '/twitter/123' }
      end

      describe 'edit_tweet_path' do
        specify { edit_tweet_path(@tweet).should == '/twitter/123/edit' }
      end

      describe 'edit_tweet_path' do
        specify { edit_tweet_path(@tweet).should == '/twitter/123/edit' }
      end
    end
  end
end
