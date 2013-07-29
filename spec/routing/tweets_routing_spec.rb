require 'spec_helper'

describe TweetsController do
  describe 'routing' do
    specify { expect(get: '/twitter').to route_to('tweets#index') }
    specify { expect(get: '/twitter/new').to route_to('tweets#new') }
    specify { expect(get: '/twitter/123').to route_to('tweets#show', id: '123') }
    specify { expect(get: '/twitter/123/edit').to route_to('tweets#edit', id: '123') }
    specify { expect(put: '/twitter/123').to route_to('tweets#update', id: '123') }
    specify { expect(delete: '/twitter/123').to route_to('tweets#destroy', id: '123') }
    specify { expect(post: '/twitter').to route_to('tweets#create') }

    describe 'index pagination' do
      specify { expect(get: '/twitter/page/2').to route_to('tweets#index', page: '2') }

      it 'rejects non-numeric :page params' do
        expect(get: '/twitter/page/foo').to_not be_routable
      end
    end

    describe 'comments' do
      # only #new, #create and #update are implemented while nested
      specify { expect(get: 'twitter/123/comments/new').to route_to('comments#new', tweet_id: '123') }
      specify { expect(post: 'twitter/123/comments').to route_to('comments#create', tweet_id: '123') }
      specify { expect(put: 'twitter/123/comments/456').to route_to('comments#update', tweet_id: '123', id: '456') }

      # all other RESTful actions are no-ops
      specify { expect(get: 'twitter/123/comments').to_not be_routable }
      specify { expect(get: '/twitter/123/comments/456').to_not be_routable }
      specify { expect(get: '/twitter/123/comments/456/edit').to_not be_routable }
      specify { expect(delete: '/twitter/123/comments/456').to_not be_routable }
    end

    describe 'helpers' do
      let(:tweet) { Tweet.stub }

      describe 'tweets_path' do
        specify { expect(tweets_path).to eq('/twitter') }
      end

      describe 'new_tweet_path' do
        specify { expect(new_tweet_path).to eq('/twitter/new') }
      end

      describe 'tweet_path' do
        specify { expect(tweet_path(tweet)).to eq("/twitter/#{tweet.id}") }
      end

      describe 'edit_tweet_path' do
        specify { expect(edit_tweet_path(tweet)).to eq("/twitter/#{tweet.id}/edit") }
      end

      describe 'edit_tweet_path' do
        specify { expect(edit_tweet_path(tweet)).to eq("/twitter/#{tweet.id}/edit") }
      end
    end
  end
end
