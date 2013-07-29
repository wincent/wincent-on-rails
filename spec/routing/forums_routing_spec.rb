require 'spec_helper'

describe ForumsController do
  describe 'routing' do
    specify { expect(get: '/forums').to route_to('forums#index') }
    specify { expect(get: '/forums/new').to route_to('forums#new') }
    specify { expect(get: '/forums/foo-bar').to route_to('forums#show', id: 'foo-bar') }
    specify { expect(get: '/forums/foo-bar/edit').to route_to('forums#edit', id: 'foo-bar') }
    specify { expect(put: '/forums/foo-bar').to route_to('forums#update', id: 'foo-bar') }
    specify { expect(delete: '/forums/foo-bar').to route_to('forums#destroy', id: 'foo-bar') }
    specify { expect(post: '/forums').to route_to('forums#create') }

    describe 'topics' do
      # only #new, #show, #edit, #update, #destroy, #create implemented while nested
      specify { expect(get: '/forums/foo-bar/topics/new').to route_to('topics#new', forum_id: 'foo-bar') }
      specify { expect(get: '/forums/foo-bar/topics/123').to route_to('topics#show', forum_id: 'foo-bar', id: '123') }
      specify { expect(get: '/forums/foo-bar/topics/123/edit').to route_to('topics#edit', forum_id: 'foo-bar', id: '123') }
      specify { expect(put: '/forums/foo-bar/topics/123').to route_to('topics#update', forum_id: 'foo-bar', id: '123') }
      specify { expect(delete: '/forums/foo-bar/topics/123').to route_to('topics#destroy', forum_id: 'foo-bar', id: '123') }
      specify { expect(post: '/forums/foo-bar/topics').to route_to('topics#create', forum_id: 'foo-bar') }

      # topics#index is a no-op here, users go to forums#show to see a list of topics
      specify { expect(get: '/forums/foo-bar/topics').to_not be_routable }
    end

    describe 'helpers' do
      let(:forum) { Forum.stub permalink: 'foo-bar' }
      let(:topic) { Topic.stub forum: forum }

      describe 'forums_path' do
        specify { expect(forums_path).to eq('/forums') }
      end

      describe 'new_forum_path' do
        specify { expect(new_forum_path).to eq('/forums/new') }
      end

      describe 'forum_path' do
        specify { expect(forum_path(forum)).to eq('/forums/foo-bar') }
      end

      describe 'edit_forum_path' do
        specify { expect(edit_forum_path(forum)).to eq('/forums/foo-bar/edit') }
      end

      describe 'forum_topics_path' do
        specify { expect(forum_topics_path(forum)).to eq('/forums/foo-bar/topics') }
      end

      describe 'new_forum_topic_path' do
        specify { expect(new_forum_topic_path(forum)).to eq('/forums/foo-bar/topics/new') }
      end

      describe 'forum_topic_path' do
        specify { expect(forum_topic_path(forum, topic)).to eq("/forums/foo-bar/topics/#{topic.id}") }
      end

      describe 'edit_forum_topic_path' do
        specify { expect(edit_forum_topic_path(forum, topic)).to eq("/forums/foo-bar/topics/#{topic.id}/edit") }
      end
    end
  end
end
