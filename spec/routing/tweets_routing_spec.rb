require 'spec_helper'

describe TweetsController do
  describe 'routing' do
    specify { get('/twitter').should have_routing('tweets#index') }
    specify { get('/twitter/new').should have_routing('tweets#new') }
    specify { get('/twitter/123').should have_routing('tweets#show', :id => '123') }
    specify { get('/twitter/123/edit').should have_routing('tweets#edit', :id => '123') }
    specify { put('/twitter/123').should have_routing('tweets#update', :id => '123') }
    specify { delete('/twitter/123').should have_routing('tweets#destroy', :id => '123') }
    specify { post('/twitter').should have_routing('tweets#create') }

    describe 'index pagination' do
      specify { get('/twitter/page/2').should have_routing('tweets#index', :page => '2') }

      it 'rejects non-numeric :page params' do
        get('/twitter/page/foo').should_not be_recognized
      end
    end

    describe 'comments' do
      # only #new, #create and #update are implemented while nested
      specify { get('/twitter/123/comments/new').should have_routing('comments#new', :tweet_id => '123') }
      specify { post('/twitter/123/comments').should have_routing('comments#create', :tweet_id => '123') }
      specify { put('/twitter/123/comments/456').should have_routing('comments#update', :tweet_id => '123', :id => '456') }

      # all other RESTful actions are no-ops
      specify { get('/twitter/123/comments').should_not be_recognized }
      specify { get('/twitter/123/comments/456').should_not be_recognized }
      specify { get('/twitter/123/comments/456/edit').should_not be_recognized }
      specify { delete('/twitter/123/comments/456').should_not be_recognized }
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
