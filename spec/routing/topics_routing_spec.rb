require 'spec_helper'

describe TopicsController do
  # as a nested resource, most of these routes are tested in forums_routing_spec.rb
  describe 'routing' do
    # only #index, #show and #destroy implemented at this level
    specify { get('/topics').should have_routing('topics#index') }
    specify { get('/topics/123').should have_routing('topics#show', :id => '123') }
    specify { delete('/topics/123').should have_routing('topics#destroy', :id => '123') }

    # the other RESTful actions are no-ops here
    specify { get('/topics/123/edit').should_not be_recognized }
    specify { put('/topics/123').should_not be_recognized }
    specify { post('/topics').should_not be_recognized }

    # as #new is not implemented, this gets routed to #show
    specify { get('/topics/new').should have_routing('topics#show', :id => 'new') }

    describe 'comments' do
      # only #new, #create and #update are implemented while nested
      specify { get('/topics/123/comments/new').should have_routing('comments#new', :topic_id => '123') }
      specify { post('/topics/123/comments').should have_routing('comments#create', :topic_id => '123') }
      specify { put('/topics/123/comments/456').should have_routing('comments#update', :topic_id => '123', :id => '456') }

      # all other RESTful actions are no-ops
      specify { get('/topics/123/comments').should_not be_recognized }
      specify { get('/topics/123/comments/456').should_not be_recognized }
      specify { get('/topics/123/comments/456/edit').should_not be_recognized }
      specify { delete('/topics/123/comments/456').should_not be_recognized }
    end

    describe 'helpers' do
      before do
        @topic = Topic.stub
      end

      describe 'topics_path' do
        specify { topics_path.should == '/topics' }
      end

      describe 'topic_path' do
        specify { topic_path(@topic).should == "/topics/#{@topic.id}" }
      end

      describe 'topic_comments_path' do
        specify { topic_comments_path(@topic).should == "/topics/#{@topic.id}/comments" }
      end

      describe 'new_topic_comment_path' do
        specify { new_topic_comment_path(@topic).should == "/topics/#{@topic.id}/comments/new" }
      end
    end
  end
end
