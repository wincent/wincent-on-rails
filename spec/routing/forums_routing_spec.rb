require 'spec_helper'

describe ForumsController do
  describe 'routing' do
    specify { expect(get: '/forums').to route_to('forums#index') }
    specify { expect(get: '/forums/foo-bar').to route_to('forums#show', id: 'foo-bar') }

    describe 'topics' do
      specify { expect(get: '/forums/foo-bar/topics/123').to route_to('topics#show', forum_id: 'foo-bar', id: '123') }

      # topics#index is a no-op here, users go to forums#show to see a list of topics
      specify { expect(get: '/forums/foo-bar/topics').to_not be_routable }
    end

    describe 'helpers' do
      let(:forum) { Forum.stub permalink: 'foo-bar' }
      let(:topic) { Topic.stub forum: forum }

      describe 'forums_path' do
        specify { expect(forums_path).to eq('/forums') }
      end

      describe 'forum_path' do
        specify { expect(forum_path(forum)).to eq('/forums/foo-bar') }
      end

      describe 'forum_topic_path' do
        specify { expect(forum_topic_path(forum, topic)).to eq("/forums/foo-bar/topics/#{topic.id}") }
      end
    end
  end
end
