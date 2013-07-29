require 'spec_helper'

describe TopicsController do
  # as a nested resource, most of these routes are tested in forums_routing_spec.rb
  describe 'routing' do
    # only #index, #show and #destroy implemented at this level
    specify { expect(get: '/topics').to route_to('topics#index') }
    specify { expect(get: '/topics/123').to route_to('topics#show', id: '123') }
    specify { expect(delete: '/topics/123').to route_to('topics#destroy', id: '123') }

    # the other RESTful actions are no-ops here
    specify { expect(get: '/topics/123/edit').to_not be_routable }
    specify { expect(put: '/topics/123').to_not be_routable }
    specify { expect(post: '/topics').to_not be_routable }

    # as #new is not implemented, this gets routed to #show
    specify { expect(get: '/topics/new').to route_to('topics#show', id: 'new') }

    describe 'comments' do
      # only #new, #create and #update are implemented while nested
      specify { expect(get: '/topics/123/comments/new').to route_to('comments#new', topic_id: '123') }
      specify { expect(post: '/topics/123/comments').to route_to('comments#create', topic_id: '123') }
      specify { expect(put: '/topics/123/comments/456').to route_to('comments#update', topic_id: '123', id: '456') }

      # all other RESTful actions are no-ops
      specify { expect(get: '/topics/123/comments').to_not be_routable }
      specify { expect(get: '/topics/123/comments/456').to_not be_routable }
      specify { expect(get: '/topics/123/comments/456/edit').to_not be_routable }
      specify { expect(delete: '/topics/123/comments/456').to_not be_routable }
    end

    describe 'helpers' do
      let(:topic) { Topic.stub }

      describe 'topics_path' do
        specify { expect(topics_path).to eq('/topics') }
      end

      describe 'topic_path' do
        specify { expect(topic_path(topic)).to eq("/topics/#{topic.id}") }
      end

      describe 'topic_comments_path' do
        specify { expect(topic_comments_path(topic)).to eq("/topics/#{topic.id}/comments") }
      end

      describe 'new_topic_comment_path' do
        specify { expect(new_topic_comment_path(topic)).to eq("/topics/#{topic.id}/comments/new") }
      end
    end
  end
end
