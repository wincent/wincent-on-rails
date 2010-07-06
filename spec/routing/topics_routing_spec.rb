require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe TopicsController do
  # as a nested resource, most of these routes are tested in forums_routing_spec.rb
  describe 'routing' do
    # only #index and #show implemented at this level
    specify { get('/topics').should map('topics#index') }
    specify { get('/topics/123').should map('topics#show', :id => '123') }

    # the other RESTful actions are no-ops here
    specify { get('/topics/123/edit').should_not be_recognized }
    specify { put('/topics/123').should_not be_recognized }
    specify { delete('/topics/123').should_not be_recognized }
    specify { post('/topics').should_not be_recognized }

    # as #new is not implemented, this gets routed to #show
    specify { get('/topics/new').should map('topics#show', :id => 'new') }

    describe 'helpers' do
      before do
        @topic = Topic.stub :id => 123
      end

      describe 'topics_path' do
        specify { topics_path.should == '/topics' }
      end

      describe 'topic_path' do
        specify { topic_path(@topic).should == '/topics/123' }
      end
    end
  end
end
